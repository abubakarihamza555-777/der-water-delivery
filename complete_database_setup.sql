-- =====================================================
-- COMPLETE DATABASE SETUP - SINGLE EXECUTION
-- Water Delivery App - New Project
-- URL: https://fqvdqspdqyfeblxgjozz.supabase.co
-- =====================================================
-- 
-- IMPORTANT: Run this entire script at once in the Supabase SQL Editor
-- This script creates everything needed for the database in the correct order
-- =====================================================

-- Database Configuration
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- =====================================================
-- STEP 1: ENABLE EXTENSIONS
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- =====================================================
-- STEP 2: CREATE CUSTOM ENUM TYPES
-- =====================================================

-- User roles for the multi-role system
CREATE TYPE user_role AS ENUM ('customer', 'delivery', 'admin');

-- Order status tracking through complete lifecycle
CREATE TYPE order_status AS ENUM (
    'pending',           -- Order placed by customer
    'confirmed',         -- Order confirmed by system
    'preparing',         -- Order being prepared
    'out_for_delivery',  -- Order assigned to delivery partner
    'delivered',         -- Order successfully delivered
    'cancelled'          -- Order cancelled
);

-- Payment status tracking
CREATE TYPE payment_status AS ENUM (
    'pending',           -- Payment initiated
    'paid',              -- Payment completed
    'failed',            -- Payment failed
    'refunded'           -- Payment refunded
);

-- Available payment methods
CREATE TYPE payment_method AS ENUM (
    'cash',              -- Cash on delivery
    'mobile_money',      -- Mobile money (M-Pesa, Tigo Pesa, etc.)
    'card',              -- Credit/Debit card
    'bank_transfer'      -- Bank transfer
);

-- Delivery status tracking
CREATE TYPE delivery_status AS ENUM (
    'assigned',          -- Assigned to delivery partner
    'picked_up',         -- Picked up from source
    'in_transit',        -- Currently delivering
    'delivered',         -- Successfully delivered
    'cancelled'          -- Delivery cancelled
);

-- Notification types for system messaging
CREATE TYPE notification_type AS ENUM (
    'order_update',      -- Order status changes
    'delivery_update',   -- Delivery status changes
    'payment',           -- Payment related notifications
    'system',            -- System notifications
    'promotion'          -- Promotional notifications
);

-- Transaction types for financial tracking
CREATE TYPE transaction_type AS ENUM (
    'earning',           -- Delivery partner earnings
    'withdrawal',        -- Withdrawal requests
    'bonus',             -- Performance bonuses
    'penalty',           -- Penalties or deductions
    'refund',            -- Payment refunds
    'commission'         -- Platform commissions
);

-- Vehicle types for delivery partners
CREATE TYPE vehicle_type AS ENUM (
    'motorcycle',        -- Motorcycle delivery
    'bicycle',           -- Bicycle delivery
    'car',               -- Car delivery
    'van',               -- Van delivery
    'truck'              -- Truck delivery
);

-- =====================================================
-- STEP 3: CREATE CORE FUNCTIONS
-- =====================================================

-- Function to automatically update updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
    order_count INTEGER;
    order_number TEXT;
BEGIN
    -- Get count of orders for today
    SELECT COUNT(*) INTO order_count 
    FROM orders 
    WHERE DATE(created_at) = CURRENT_DATE;
    
    -- Generate order number: ORD-YYYYMMDD-XXXX (4-digit sequence)
    order_number := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || LPAD((order_count + 1)::TEXT, 4, '0');
    
    RETURN order_number;
END;
$$ LANGUAGE plpgsql;

-- Function for order number trigger
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 4: CREATE ALL TABLES
-- =====================================================

-- Users table with multi-role support
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    profile_image_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Delivery partner specific fields
    vehicle_type vehicle_type,
    license_plate VARCHAR(20),
    vehicle_registration VARCHAR(50),
    is_online BOOLEAN DEFAULT FALSE,
    current_location POINT,
    delivery_rating DECIMAL(3,2) DEFAULT 0.00 CHECK (delivery_rating >= 0 AND delivery_rating <= 5),
    total_deliveries INTEGER DEFAULT 0,
    total_earnings DECIMAL(12,2) DEFAULT 0.00,
    available_balance DECIMAL(12,2) DEFAULT 0.00,
    
    -- Admin specific fields
    permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
    admin_level INTEGER DEFAULT 1 CHECK (admin_level >= 1 AND admin_level <= 5),
    
    -- Security fields
    password_hash VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires_at TIMESTAMP WITH TIME ZONE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    notification_settings JSONB DEFAULT '{"email": true, "sms": true, "push": true}',
    
    -- Constraints
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_phone_check CHECK (phone ~* '^[+]?[0-9]{10,15}$')
);

-- Addresses table for delivery locations
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL DEFAULT 'home',
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    street TEXT NOT NULL,
    area VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL DEFAULT 'Dar es Salaam',
    state VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Additional address details
    building_name VARCHAR(255),
    floor_number VARCHAR(20),
    apartment_number VARCHAR(20),
    landmark TEXT,
    delivery_instructions TEXT,
    
    -- Geospatial data
    coordinates geometry(POINT, 4326) NOT NULL GENERATED ALWAYS AS (ST_MakePoint(longitude, latitude)) STORED,
    
    -- Constraints
    CONSTRAINT valid_address_type CHECK (type IN ('home', 'office', 'other')),
    CONSTRAINT valid_coordinates CHECK (latitude >= -90 AND latitude <= 90 AND longitude >= -180 AND longitude <= 180)
);

-- Water types table (product catalog)
CREATE TABLE water_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    volume_liters INTEGER NOT NULL CHECK (volume_liters > 0),
    bottle_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Product details
    brand VARCHAR(100),
    source VARCHAR(100) DEFAULT 'fresh',
    purification_method TEXT,
    storage_instructions TEXT,
    shelf_life_days INTEGER,
    water_quality VARCHAR(100) DEFAULT 'premium',
    
    -- Inventory management
    stock_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 10,
    max_order_quantity INTEGER DEFAULT 50,
    
    -- Pricing details
    cost_price DECIMAL(10,2),
    discount_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    -- Category and tags
    category VARCHAR(50) DEFAULT 'water',
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Constraints
    CONSTRAINT valid_bottle_type CHECK (bottle_type IN ('plastic', 'glass', 'tank')),
    CONSTRAINT valid_source CHECK (source = 'fresh'),
    CONSTRAINT valid_water_quality CHECK (water_quality IN ('premium', 'standard'))
);

-- Orders table - central to the system
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES users(id),
    status order_status NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (delivery_fee >= 0),
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    currency VARCHAR(3) DEFAULT 'TZS',
    
    -- Delivery information
    delivery_address_id UUID NOT NULL REFERENCES addresses(id),
    delivery_instructions TEXT,
    preferred_delivery_time TIMESTAMP WITH TIME ZONE,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    delivery_distance_km DECIMAL(8,2),
    
    -- Payment information
    payment_status payment_status NOT NULL DEFAULT 'pending',
    payment_method payment_method,
    payment_reference VARCHAR(255),
    paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Delivery partner assignment
    delivery_partner_id UUID REFERENCES users(id),
    
    -- Timestamps for order lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    preparing_at TIMESTAMP WITH TIME ZONE,
    out_for_delivery_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    
    -- Cancellation details
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES users(id),
    
    -- Metadata
    source VARCHAR(50) DEFAULT 'mobile_app',
    notes TEXT,
    priority_level INTEGER DEFAULT 1 CHECK (priority_level >= 1 AND priority_level <= 5),
    
    -- Additional data
    customer_location POINT,
    delivery_location POINT,
    zone_id UUID REFERENCES zones(id),
    
    -- Constraints
    CONSTRAINT valid_order_total CHECK (total_amount = subtotal + delivery_fee + tax_amount - discount_amount)
);

-- Order items table - detailed order contents
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    water_type_id UUID NOT NULL REFERENCES water_types(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Product snapshot at time of order
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    product_image_url TEXT,
    volume_liters INTEGER NOT NULL,
    bottle_type VARCHAR(50) NOT NULL,
    
    -- Constraints
    CONSTRAINT valid_order_item_total CHECK (total_price = unit_price * quantity)
);

-- Deliveries table - detailed delivery tracking
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    status delivery_status NOT NULL DEFAULT 'assigned',
    
    -- Location tracking
    pickup_location POINT,
    delivery_location POINT,
    current_location POINT,
    pickup_address TEXT,
    delivery_address TEXT,
    
    -- Timing
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivery_time TIMESTAMP WITH TIME ZONE,
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    
    -- Distance and route
    distance_km DECIMAL(8,2),
    route_coordinates JSONB,
    
    -- Financial details
    delivery_fee DECIMAL(10,2) NOT NULL CHECK (delivery_fee >= 0),
    commission_percentage DECIMAL(5,2) DEFAULT 20.00 CHECK (commission_percentage >= 0 AND commission_percentage <= 100),
    commission_amount DECIMAL(10,2),
    platform_fee DECIMAL(10,2),
    net_earnings DECIMAL(10,2),
    
    -- Customer feedback
    customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5),
    customer_feedback TEXT,
    
    -- Delivery proof
    delivery_photo_url TEXT,
    signature_url TEXT,
    recipient_name VARCHAR(255),
    recipient_phone VARCHAR(20),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    picked_up_at TIMESTAMP WITH TIME ZONE,
    in_transit_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    
    -- Cancellation details
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT valid_commission_amount CHECK (commission_amount = delivery_fee * commission_percentage / 100),
    CONSTRAINT valid_net_earnings CHECK (net_earnings = commission_amount - platform_fee)
);

-- Payments table - comprehensive payment processing
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'TZS',
    status payment_status NOT NULL DEFAULT 'pending',
    method payment_method NOT NULL,
    
    -- Payment gateway details
    gateway_transaction_id VARCHAR(255),
    gateway_reference VARCHAR(255),
    gateway_response JSONB,
    gateway_provider VARCHAR(50) DEFAULT 'stripe',
    
    -- Mobile money specific
    mobile_provider VARCHAR(50),
    mobile_number VARCHAR(20),
    mobile_transaction_id VARCHAR(255),
    
    -- Card specific
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    card_exp_month INTEGER,
    card_exp_year INTEGER,
    
    -- Bank transfer specific
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    transaction_reference VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    
    -- Failure and refund details
    failure_reason TEXT,
    refund_reason TEXT,
    refund_amount DECIMAL(10,2),
    
    -- Security
    ip_address INET,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    
    -- Metadata
    description TEXT,
    metadata JSONB
);

-- Transactions table - financial tracking for all users
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type transaction_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    description TEXT NOT NULL,
    
    -- Related entities
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    payment_id UUID REFERENCES payments(id),
    
    -- Status and processing
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    
    -- Withdrawal specific
    withdrawal_method VARCHAR(50),
    withdrawal_details JSONB,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Financial details
    balance_before DECIMAL(12,2),
    balance_after DECIMAL(12,2),
    fee_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadata
    reference_number VARCHAR(255) UNIQUE,
    notes TEXT,
    metadata JSONB,
    
    -- Constraints
    CONSTRAINT valid_balance_change CHECK (balance_after = balance_before + amount - fee_amount - tax_amount)
);

-- Zones table - delivery area management
CREATE TABLE zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 2000.00 CHECK (base_delivery_fee >= 0),
    fee_per_km DECIMAL(10,2) NOT NULL DEFAULT 500.00 CHECK (fee_per_km >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1 CHECK (priority >= 1),
    
    -- Coverage details
    coverage_areas JSONB,
    center_lat DECIMAL(10,8),
    center_lng DECIMAL(11,8),
    radius_km DECIMAL(8,2),
    
    -- Operational settings
    operating_hours JSONB DEFAULT '{"start": "06:00", "end": "22:00"}',
    delivery_time_estimate INTEGER DEFAULT 60,
    max_delivery_distance_km DECIMAL(8,2) DEFAULT 20.00,
    
    -- Capacity management
    max_active_deliveries INTEGER DEFAULT 50,
    current_active_deliveries INTEGER DEFAULT 0,
    
    -- Geospatial boundary
    area_boundary GEOMETRY(POLYGON, 4326),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_radius CHECK (radius_km > 0),
    CONSTRAINT valid_capacity CHECK (current_active_deliveries <= max_active_deliveries)
);

-- Zone assignments - delivery partners to zones
CREATE TABLE zone_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    zone_id UUID NOT NULL REFERENCES zones(id),
    is_primary BOOLEAN DEFAULT FALSE,
    priority INTEGER DEFAULT 1 CHECK (priority >= 1),
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Assignment details
    assigned_by UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Performance tracking
    total_deliveries INTEGER DEFAULT 0,
    successful_deliveries INTEGER DEFAULT 0,
    cancelled_deliveries INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(delivery_partner_id, zone_id)
);

-- Notifications table - comprehensive notification system
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    
    -- Status tracking
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Push notification
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP WITH TIME ZONE,
    push_response JSONB,
    
    -- Email notification
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMP WITH TIME ZONE,
    email_response JSONB,
    
    -- SMS notification
    sms_sent BOOLEAN DEFAULT FALSE,
    sms_sent_at TIMESTAMP WITH TIME ZONE,
    sms_response JSONB,
    
    -- Related entities
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    payment_id UUID REFERENCES payments(id),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Expiration
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Priority
    priority_level INTEGER DEFAULT 1 CHECK (priority_level >= 1 AND priority_level <= 5)
);

-- Reviews table - customer feedback system
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    delivery_partner_id UUID REFERENCES users(id),
    
    -- Ratings
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    delivery_speed_rating INTEGER CHECK (delivery_speed_rating >= 1 AND delivery_speed_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    product_quality_rating INTEGER CHECK (product_quality_rating >= 1 AND product_quality_rating <= 5),
    
    -- Feedback
    comment TEXT,
    
    -- Response from delivery partner
    partner_response TEXT,
    partner_responded_at TIMESTAMP WITH TIME ZONE,
    
    -- Admin moderation
    is_public BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Flags
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Withdrawal requests table
CREATE TABLE withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'TZS',
    method VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    
    -- Bank details
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    bank_code VARCHAR(20),
    
    -- Mobile money details
    mobile_provider VARCHAR(50),
    mobile_number VARCHAR(20),
    mobile_account_name VARCHAR(255),
    
    -- Processing details
    processed_by UUID REFERENCES users(id),
    processed_at TIMESTAMP WITH TIME ZONE,
    transaction_reference VARCHAR(255),
    
    -- Fees
    processing_fee DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    net_amount DECIMAL(12,2),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Notes
    notes TEXT,
    rejection_reason TEXT,
    
    -- Constraints
    CONSTRAINT valid_net_amount CHECK (net_amount = amount - processing_fee - tax_amount)
);

-- Support tickets table
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    
    -- Related entities
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    
    -- Assignment
    assigned_to UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    
    -- Resolution
    resolution TEXT,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_response_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    attachments JSONB,
    metadata JSONB
);

-- Promotions table
CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    code VARCHAR(50) UNIQUE,
    type VARCHAR(50) NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    
    -- Applicability
    applicable_users JSONB,
    applicable_zones JSONB,
    applicable_products JSONB,
    
    -- Usage limits
    usage_limit INTEGER,
    usage_limit_per_user INTEGER,
    current_usage INTEGER DEFAULT 0,
    
    -- Validity
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Created by
    created_by UUID REFERENCES users(id)
);

-- Promotion usage tracking
CREATE TABLE promotion_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promotion_id UUID NOT NULL REFERENCES promotions(id),
    user_id UUID NOT NULL REFERENCES users(id),
    order_id UUID NOT NULL REFERENCES orders(id),
    discount_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(promotion_id, user_id, order_id)
);

-- =====================================================
-- STEP 5: CREATE INDEXES
-- =====================================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_is_online ON users(is_online);
CREATE INDEX idx_users_current_location ON users USING GIST(current_location);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Addresses table indexes
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_is_default ON addresses(is_default);
CREATE INDEX idx_addresses_coordinates ON addresses USING GIST(coordinates);
CREATE INDEX idx_addresses_location ON addresses USING GIST(ST_MakePoint(longitude, latitude));
CREATE INDEX idx_addresses_city ON addresses(city);
CREATE INDEX idx_addresses_area ON addresses(area);

-- Water types table indexes
CREATE INDEX idx_water_types_is_active ON water_types(is_active);
CREATE INDEX idx_water_types_category ON water_types(category);
CREATE INDEX idx_water_types_price ON water_types(price);
CREATE INDEX idx_water_types_volume ON water_types(volume_liters);

-- Orders table indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_delivery_partner_id ON orders(delivery_partner_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_zone_id ON orders(zone_id);
CREATE INDEX idx_orders_total_amount ON orders(total_amount);

-- Order items table indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_water_type_id ON order_items(water_type_id);
CREATE INDEX idx_order_items_quantity ON order_items(quantity);

-- Deliveries table indexes
CREATE INDEX idx_deliveries_order_id ON deliveries(order_id);
CREATE INDEX idx_deliveries_delivery_partner_id ON deliveries(delivery_partner_id);
CREATE INDEX idx_deliveries_status ON deliveries(status);
CREATE INDEX idx_deliveries_created_at ON deliveries(created_at);
CREATE INDEX idx_deliveries_current_location ON deliveries USING GIST(current_location);
CREATE INDEX idx_deliveries_pickup_location ON deliveries USING GIST(pickup_location);
CREATE INDEX idx_deliveries_delivery_location ON deliveries USING GIST(delivery_location);

-- Payments table indexes
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_method ON payments(method);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_gateway_transaction_id ON payments(gateway_transaction_id);

-- Transactions table indexes
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_reference_number ON transactions(reference_number);

-- Zones table indexes
CREATE INDEX idx_zones_is_active ON zones(is_active);
CREATE INDEX idx_zones_priority ON zones(priority);
CREATE INDEX idx_zones_area_boundary ON zones USING GIST(area_boundary);
CREATE INDEX idx_zones_center_point ON zones USING GIST(ST_MakePoint(center_lng, center_lat));

-- Zone assignments table indexes
CREATE INDEX idx_zone_assignments_delivery_partner_id ON zone_assignments(delivery_partner_id);
CREATE INDEX idx_zone_assignments_zone_id ON zone_assignments(zone_id);
CREATE INDEX idx_zone_assignments_is_active ON zone_assignments(is_active);
CREATE INDEX idx_zone_assignments_is_primary ON zone_assignments(is_primary);

-- Notifications table indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_expires_at ON notifications(expires_at);
CREATE INDEX idx_notifications_priority_level ON notifications(priority_level);

-- Reviews table indexes
CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_delivery_partner_id ON reviews(delivery_partner_id);
CREATE INDEX idx_reviews_overall_rating ON reviews(overall_rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_reviews_is_public ON reviews(is_public);
CREATE INDEX idx_reviews_is_verified ON reviews(is_verified);

-- Withdrawal requests table indexes
CREATE INDEX idx_withdrawal_requests_user_id ON withdrawal_requests(user_id);
CREATE INDEX idx_withdrawal_requests_status ON withdrawal_requests(status);
CREATE INDEX idx_withdrawal_requests_created_at ON withdrawal_requests(created_at);

-- Support tickets table indexes
CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_category ON support_tickets(category);
CREATE INDEX idx_support_tickets_priority ON support_tickets(priority);
CREATE INDEX idx_support_tickets_assigned_to ON support_tickets(assigned_to);
CREATE INDEX idx_support_tickets_created_at ON support_tickets(created_at);

-- Promotions table indexes
CREATE INDEX idx_promotions_is_active ON promotions(is_active);
CREATE INDEX idx_promotions_code ON promotions(code);
CREATE INDEX idx_promotions_starts_at ON promotions(starts_at);
CREATE INDEX idx_promotions_expires_at ON promotions(expires_at);

-- Promotion usage table indexes
CREATE INDEX idx_promotion_usage_promotion_id ON promotion_usage(promotion_id);
CREATE INDEX idx_promotion_usage_user_id ON promotion_usage(user_id);
CREATE INDEX idx_promotion_usage_created_at ON promotion_usage(created_at);

-- =====================================================
-- STEP 6: CREATE TRIGGERS
-- =====================================================

-- Apply updated_at triggers to all relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON addresses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_water_types_updated_at BEFORE UPDATE ON water_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON deliveries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_zones_updated_at BEFORE UPDATE ON zones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_zone_assignments_updated_at BEFORE UPDATE ON zone_assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_withdrawal_requests_updated_at BEFORE UPDATE ON withdrawal_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_support_tickets_updated_at BEFORE UPDATE ON support_tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_promotions_updated_at BEFORE UPDATE ON promotions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for auto-generating order numbers
CREATE TRIGGER set_order_number_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION set_order_number();

-- =====================================================
-- STEP 7: ENABLE ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE water_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE zone_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotion_usage ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 8: CREATE SECURITY FUNCTIONS
-- =====================================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION user_is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role = 'admin' AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is delivery partner
CREATE OR REPLACE FUNCTION user_is_delivery_partner()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role = 'delivery' AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is customer
CREATE OR REPLACE FUNCTION user_is_customer()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role = 'customer' AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STEP 9: CREATE RLS POLICIES
-- =====================================================

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (
        auth.uid() = id AND 
        role = old.role AND
        is_active = old.is_active AND
        is_verified = old.is_verified
    );

CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Admins can update all users" ON users
    FOR UPDATE USING (user_is_admin());

CREATE POLICY "Service can insert users" ON users
    FOR INSERT WITH CHECK (true);

-- Addresses table policies
CREATE POLICY "Users can view own addresses" ON addresses
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own addresses" ON addresses
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own addresses" ON addresses
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own addresses" ON addresses
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "Admins can view all addresses" ON addresses
    FOR SELECT USING (user_is_admin());

-- Water types table policies
CREATE POLICY "Authenticated users can view water types" ON water_types
    FOR SELECT USING (is_active = true AND auth.role() = 'authenticated');

CREATE POLICY "Admins can manage water types" ON water_types
    FOR ALL USING (user_is_admin());

-- Orders table policies
CREATE POLICY "Customers can view own orders" ON orders
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Delivery partners can view assigned orders" ON orders
    FOR SELECT USING (delivery_partner_id = auth.uid());

CREATE POLICY "Admins can view all orders" ON orders
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Customers can insert own orders" ON orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());

CREATE POLICY "Delivery partners can update assigned orders" ON orders
    FOR UPDATE USING (
        delivery_partner_id = auth.uid() AND
        status IN ('out_for_delivery', 'delivered')
    );

CREATE POLICY "Admins can update all orders" ON orders
    FOR UPDATE USING (user_is_admin());

-- Order items table policies
CREATE POLICY "Users can view own order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = order_items.order_id AND 
            (customer_id = auth.uid() OR delivery_partner_id = auth.uid() OR user_is_admin())
        )
    );

CREATE POLICY "Service can manage order items" ON order_items
    FOR ALL WITH CHECK (true);

-- Deliveries table policies
CREATE POLICY "Delivery partners can view own deliveries" ON deliveries
    FOR SELECT USING (delivery_partner_id = auth.uid());

CREATE POLICY "Customers can view own deliveries" ON deliveries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = deliveries.order_id AND customer_id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all deliveries" ON deliveries
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Delivery partners can update own deliveries" ON deliveries
    FOR UPDATE USING (delivery_partner_id = auth.uid());

CREATE POLICY "Admins can update all deliveries" ON deliveries
    FOR UPDATE USING (user_is_admin());

CREATE POLICY "Service can insert deliveries" ON deliveries
    FOR INSERT WITH CHECK (true);

-- Payments table policies
CREATE POLICY "Customers can view own payments" ON payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = payments.order_id AND customer_id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all payments" ON payments
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Service can manage payments" ON payments
    FOR ALL WITH CHECK (true);

-- Transactions table policies
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert withdrawal requests" ON transactions
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND 
        type = 'withdrawal'
    );

CREATE POLICY "Admins can view all transactions" ON transactions
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Admins can update all transactions" ON transactions
    FOR UPDATE USING (user_is_admin());

CREATE POLICY "Service can insert earnings" ON transactions
    FOR INSERT WITH CHECK (
        type IN ('earning', 'bonus', 'penalty', 'commission')
    );

-- Zones table policies
CREATE POLICY "Authenticated users can view zones" ON zones
    FOR SELECT USING (is_active = true AND auth.role() = 'authenticated');

CREATE POLICY "Admins can manage zones" ON zones
    FOR ALL USING (user_is_admin());

-- Zone assignments table policies
CREATE POLICY "Delivery partners can view own zone assignments" ON zone_assignments
    FOR SELECT USING (delivery_partner_id = auth.uid());

CREATE POLICY "Admins can view all zone assignments" ON zone_assignments
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Admins can manage zone assignments" ON zone_assignments
    FOR ALL USING (user_is_admin());

CREATE POLICY "Service can manage zone assignments" ON zone_assignments
    FOR ALL WITH CHECK (true);

-- Notifications table policies
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Service can manage notifications" ON notifications
    FOR ALL WITH CHECK (true);

-- Reviews table policies
CREATE POLICY "Users can view public reviews" ON reviews
    FOR SELECT USING (is_public = true);

CREATE POLICY "Customers can view own reviews" ON reviews
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Delivery partners can view own reviews" ON reviews
    FOR SELECT USING (delivery_partner_id = auth.uid());

CREATE POLICY "Admins can view all reviews" ON reviews
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Customers can insert reviews" ON reviews
    FOR INSERT WITH CHECK (
        customer_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = reviews.order_id AND 
            customer_id = auth.uid() AND 
            status = 'delivered'
        )
    );

CREATE POLICY "Customers can update own reviews" ON reviews
    FOR UPDATE USING (customer_id = auth.uid());

CREATE POLICY "Delivery partners can respond to reviews" ON reviews
    FOR UPDATE USING (
        delivery_partner_id = auth.uid() AND
        partner_response IS NOT NULL
    );

CREATE POLICY "Admins can update all reviews" ON reviews
    FOR UPDATE USING (user_is_admin());

-- Withdrawal requests table policies
CREATE POLICY "Users can view own withdrawal requests" ON withdrawal_requests
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert withdrawal requests" ON withdrawal_requests
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can view all withdrawal requests" ON withdrawal_requests
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Admins can update all withdrawal requests" ON withdrawal_requests
    FOR UPDATE USING (user_is_admin());

-- Support tickets table policies
CREATE POLICY "Users can view own support tickets" ON support_tickets
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert support tickets" ON support_tickets
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own support tickets" ON support_tickets
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Admins can view all support tickets" ON support_tickets
    FOR SELECT USING (user_is_admin());

CREATE POLICY "Admins can update all support tickets" ON support_tickets
    FOR UPDATE USING (user_is_admin());

-- Promotions table policies
CREATE POLICY "Authenticated users can view promotions" ON promotions
    FOR SELECT USING (
        is_active = true AND 
        auth.role() = 'authenticated' AND
        (starts_at IS NULL OR starts_at <= NOW()) AND
        (expires_at IS NULL OR expires_at > NOW())
    );

CREATE POLICY "Admins can manage promotions" ON promotions
    FOR ALL USING (user_is_admin());

-- Promotion usage table policies
CREATE POLICY "Users can view own promotion usage" ON promotion_usage
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Service can manage promotion usage" ON promotion_usage
    FOR ALL WITH CHECK (true);

-- =====================================================
-- STEP 10: GRANT PERMISSIONS
-- =====================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- Grant limited permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON addresses TO authenticated;
GRANT SELECT ON water_types TO authenticated;
GRANT SELECT, INSERT ON orders TO authenticated;
GRANT SELECT ON order_items TO authenticated;
GRANT SELECT, UPDATE ON deliveries TO authenticated;
GRANT SELECT ON payments TO authenticated;
GRANT SELECT, INSERT ON transactions TO authenticated;
GRANT SELECT, UPDATE ON notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE ON reviews TO authenticated;
GRANT SELECT ON zones TO authenticated;
GRANT SELECT ON zone_assignments TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON withdrawal_requests TO authenticated;
GRANT SELECT, INSERT, UPDATE ON support_tickets TO authenticated;
GRANT SELECT ON promotions TO authenticated;
GRANT SELECT ON promotion_usage TO authenticated;

-- Grant read-only permissions to anonymous users
GRANT SELECT ON water_types TO anon;
GRANT SELECT ON zones TO anon;
GRANT SELECT ON promotions TO anon;

-- =====================================================
-- STEP 11: INSERT ESSENTIAL DATA
-- =====================================================

-- Insert basic water types required for the app to function
INSERT INTO water_types (
    name, 
    description, 
    price, 
    volume_liters, 
    bottle_type, 
    brand,
    source,
    purification_method,
    storage_instructions,
    shelf_life_days,
    water_quality,
    stock_quantity,
    reorder_level,
    max_order_quantity,
    cost_price,
    category,
    tags,
    is_active
) VALUES
(
    'Standard Purified Water',
    '20L bottle of purified drinking water',
    5000.00,
    20,
    'plastic',
    'Dar Water',
    'fresh',
    'Reverse osmosis and UV treatment',
    'Store in cool, dry place away from direct sunlight',
    365,
    'premium',
    1000,
    100,
    10,
    3000.00,
    'water',
    ARRAY['purified', 'drinking', 'standard'],
    true
),
(
    'Mineral Water',
    '20L bottle of natural mineral water',
    7000.00,
    20,
    'plastic',
    'Dar Mineral',
    'fresh',
    'Natural mineral filtration',
    'Store in cool, dry place away from direct sunlight',
    365,
    'premium',
    500,
    50,
    10,
    4500.00,
    'water',
    ARRAY['mineral', 'natural', 'premium'],
    true
),
(
    'Spring Water',
    '20L bottle of spring water',
    6500.00,
    20,
    'plastic',
    'Dar Spring',
    'fresh',
    'Spring source filtration',
    'Store in cool, dry place away from direct sunlight',
    365,
    'premium',
    750,
    75,
    10,
    4000.00,
    'water',
    ARRAY['spring', 'natural', 'fresh'],
    true
);

-- Insert basic zones for Dar es Salaam (required for delivery operations)
INSERT INTO zones (
    name,
    description,
    base_delivery_fee,
    fee_per_km,
    is_active,
    priority,
    coverage_areas,
    center_lat,
    center_lng,
    radius_km,
    operating_hours,
    delivery_time_estimate,
    max_delivery_distance_km,
    max_active_deliveries,
    current_active_deliveries,
    area_boundary
) VALUES
(
    'City Center',
    'Central business district and surrounding areas',
    2000.00,
    500.00,
    true,
    1,
    ARRAY['Kivukoni', 'Kariakoo', 'Mchikichini', 'Upanga', 'Ilala', 'Gerezani'],
    -6.7874,
    39.2133,
    5.0,
    '{"start": "06:00", "end": "22:00"}',
    45,
    15.0,
    100,
    0,
    ST_GeomFromText('POLYGON((39.2083 -6.7924, 39.2183 -6.7924, 39.2183 -6.7824, 39.2083 -6.7824, 39.2083 -6.7924))', 4326)
),
(
    'Kinondoni',
    'Major residential and commercial hub',
    2500.00,
    550.00,
    true,
    2,
    ARRAY['Kinondoni', 'Hananasif', 'Mwenge', 'Kijitonyama', 'Kawe', 'Bunju'],
    -6.8224,
    39.1883,
    8.0,
    '{"start": "06:00", "end": "22:00"}',
    60,
    20.0,
    80,
    0,
    ST_GeomFromText('POLYGON((39.1833 -6.8224, 39.1933 -6.8224, 39.1933 -6.8124, 39.1833 -6.8124, 39.1833 -6.8224))', 4326)
),
(
    'Oysterbay',
    'Upscale residential and commercial area',
    3000.00,
    600.00,
    true,
    3,
    ARRAY['Oysterbay', 'Masaki', 'Regent Estate', 'Mikocheni', 'Ada Estate'],
    -6.7624,
    39.2883,
    6.0,
    '{"start": "06:00", "end": "22:00"}',
    50,
    18.0,
    60,
    0,
    ST_GeomFromText('POLYGON((39.2833 -6.7624, 39.2933 -6.7624, 39.2933 -6.7524, 39.2833 -6.7524, 39.2833 -6.7624))', 4326)
),
(
    'Temeke',
    'Industrial and residential area',
    2200.00,
    520.00,
    true,
    4,
    ARRAY['Temeke', 'Chang''ombe', 'Mtoni', 'Kisutu', 'Mbagala'],
    -6.8574,
    39.2683,
    10.0,
    '{"start": "06:00", "end": "21:00"}',
    70,
    25.0,
    70,
    0,
    ST_GeomFromText('POLYGON((39.2583 -6.8574, 39.2783 -6.8574, 39.2783 -6.8474, 39.2583 -6.8474, 39.2583 -6.8574))', 4326)
);

-- Insert a system admin user (password will be set separately)
INSERT INTO users (
    email,
    name,
    phone,
    role,
    is_verified,
    is_active,
    admin_level,
    permissions,
    preferred_language,
    notification_settings
) VALUES
(
    'admin@darwaterdelivery.com',
    'System Administrator',
    '+255123456789',
    'admin',
    true,
    true,
    5,
    ARRAY['all'],
    'en',
    '{"email": true, "sms": true, "push": true}'
);

-- =====================================================
-- STEP 12: VERIFICATION
-- =====================================================

-- Verify essential data was inserted
DO $$
DECLARE
    water_types_count INTEGER;
    zones_count INTEGER;
    admin_count INTEGER;
    tables_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO water_types_count FROM water_types WHERE is_active = true;
    SELECT COUNT(*) INTO zones_count FROM zones WHERE is_active = true;
    SELECT COUNT(*) INTO admin_count FROM users WHERE role = 'admin';
    SELECT COUNT(*) INTO tables_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    
    RAISE NOTICE '=== DATABASE SETUP COMPLETED SUCCESSFULLY ===';
    RAISE NOTICE 'Database URL: https://fqvdqspdqyfeblxgjozz.supabase.co';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables created: %', tables_count;
    RAISE NOTICE 'Water types: %', water_types_count;
    RAISE NOTICE 'Active zones: %', zones_count;
    RAISE NOTICE 'Admin users: %', admin_count;
    RAISE NOTICE '';
    
    IF water_types_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No water types found - app will not function properly';
    END IF;
    
    IF zones_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No zones found - delivery operations will fail';
    END IF;
    
    IF admin_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No admin users found - system management will be limited';
    END IF;
    
    RAISE NOTICE '✅ Database is ready for production use!';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Set admin password through Supabase Auth';
    RAISE NOTICE '2. Test the application';
    RAISE NOTICE '3. Configure storage buckets if needed';
END $$;

-- =====================================================
-- SETUP COMPLETE
-- =====================================================

-- Database is now ready for production use
-- All tables, indexes, triggers, RLS policies, and essential data are in place
