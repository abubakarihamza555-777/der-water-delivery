-- =====================================================
-- WATER DELIVERY APP - CLEAN DATABASE SCHEMA
-- New Project Database - No Sample Data
-- URL: https://fqvdqspdqyfeblxgjozz.supabase.co
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

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- =====================================================
-- CUSTOM ENUM TYPES
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
-- CORE TABLES
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

-- =====================================================
-- SUPPORTING TABLES
-- =====================================================

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
-- INDEXES FOR PERFORMANCE
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
-- TRIGGERS AND FUNCTIONS
-- =====================================================

-- Function to automatically update updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

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

-- Create trigger for auto-generating order numbers
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION set_order_number();

-- Function to update zone delivery counts
CREATE OR REPLACE FUNCTION update_zone_delivery_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE zones 
        SET current_active_deliveries = current_active_deliveries + 1
        WHERE id = NEW.zone_id;
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status IN ('assigned', 'picked_up', 'in_transit') AND NEW.status IN ('delivered', 'cancelled') THEN
            UPDATE zones 
            SET current_active_deliveries = current_active_deliveries - 1
            WHERE id = NEW.zone_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE zones 
        SET current_active_deliveries = current_active_deliveries - 1
        WHERE id = OLD.zone_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for zone delivery count updates
CREATE TRIGGER update_zone_delivery_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON deliveries
    FOR EACH ROW
    EXECUTE FUNCTION update_zone_delivery_count();

-- =====================================================
-- SCHEMA COMPLETION
-- =====================================================

-- Grant necessary permissions will be handled by RLS policies
-- No sample data inserted - clean database ready for production use
