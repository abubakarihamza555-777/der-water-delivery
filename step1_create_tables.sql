-- =====================================================
-- STEP 1: CREATE TABLES ONLY
-- Water Delivery App - New Project
-- URL: https://fqvdqspdqyfeblxgjozz.supabase.co
-- =====================================================
-- 
-- This script ONLY creates the basic tables and types
-- Run this FIRST, then run step2_rls_policies.sql
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

-- =====================================================
-- CREATE CUSTOM ENUM TYPES
-- =====================================================

CREATE TYPE user_role AS ENUM ('customer', 'delivery', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('cash', 'mobile_money', 'card', 'bank_transfer');
CREATE TYPE delivery_status AS ENUM ('assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled');
CREATE TYPE notification_type AS ENUM ('order_update', 'delivery_update', 'payment', 'system', 'promotion');
CREATE TYPE transaction_type AS ENUM ('earning', 'withdrawal', 'bonus', 'penalty', 'refund', 'commission');
CREATE TYPE vehicle_type AS ENUM ('motorcycle', 'bicycle', 'car', 'van', 'truck');

-- =====================================================
-- CREATE TABLES
-- =====================================================

-- Users table
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
    vehicle_type vehicle_type,
    license_plate VARCHAR(20),
    vehicle_registration VARCHAR(50),
    is_online BOOLEAN DEFAULT FALSE,
    current_location POINT,
    delivery_rating DECIMAL(3,2) DEFAULT 0.00 CHECK (delivery_rating >= 0 AND delivery_rating <= 5),
    total_deliveries INTEGER DEFAULT 0,
    total_earnings DECIMAL(12,2) DEFAULT 0.00,
    available_balance DECIMAL(12,2) DEFAULT 0.00,
    permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
    admin_level INTEGER DEFAULT 1 CHECK (admin_level >= 1 AND admin_level <= 5),
    password_hash VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires_at TIMESTAMP WITH TIME ZONE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    preferred_language VARCHAR(10) DEFAULT 'en',
    notification_settings JSONB DEFAULT '{"email": true, "sms": true, "push": true}',
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_phone_check CHECK (phone ~* '^[+]?[0-9]{10,15}$')
);

-- Addresses table
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
    building_name VARCHAR(255),
    floor_number VARCHAR(20),
    apartment_number VARCHAR(20),
    landmark TEXT,
    delivery_instructions TEXT,
    coordinates geometry(POINT, 4326) NOT NULL GENERATED ALWAYS AS (ST_MakePoint(longitude, latitude)) STORED,
    CONSTRAINT valid_address_type CHECK (type IN ('home', 'office', 'other')),
    CONSTRAINT valid_coordinates CHECK (latitude >= -90 AND latitude <= 90 AND longitude >= -180 AND longitude <= 180)
);

-- Water types table
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
    brand VARCHAR(100),
    source VARCHAR(100) DEFAULT 'fresh',
    purification_method TEXT,
    storage_instructions TEXT,
    shelf_life_days INTEGER,
    water_quality VARCHAR(100) DEFAULT 'premium',
    stock_quantity INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 10,
    max_order_quantity INTEGER DEFAULT 50,
    cost_price DECIMAL(10,2),
    discount_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    category VARCHAR(50) DEFAULT 'water',
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    CONSTRAINT valid_bottle_type CHECK (bottle_type IN ('plastic', 'glass', 'tank')),
    CONSTRAINT valid_source CHECK (source = 'fresh'),
    CONSTRAINT valid_water_quality CHECK (water_quality IN ('premium', 'standard'))
);

-- Orders table
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
    delivery_address_id UUID NOT NULL REFERENCES addresses(id),
    delivery_instructions TEXT,
    preferred_delivery_time TIMESTAMP WITH TIME ZONE,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    delivery_distance_km DECIMAL(8,2),
    payment_status payment_status NOT NULL DEFAULT 'pending',
    payment_method payment_method,
    payment_reference VARCHAR(255),
    paid_at TIMESTAMP WITH TIME ZONE,
    delivery_partner_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    preparing_at TIMESTAMP WITH TIME ZONE,
    out_for_delivery_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES users(id),
    source VARCHAR(50) DEFAULT 'mobile_app',
    notes TEXT,
    priority_level INTEGER DEFAULT 1 CHECK (priority_level >= 1 AND priority_level <= 5),
    customer_location POINT,
    delivery_location POINT,
    zone_id UUID REFERENCES zones(id),
    CONSTRAINT valid_order_total CHECK (total_amount = subtotal + delivery_fee + tax_amount - discount_amount)
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    water_type_id UUID NOT NULL REFERENCES water_types(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    product_image_url TEXT,
    volume_liters INTEGER NOT NULL,
    bottle_type VARCHAR(50) NOT NULL,
    CONSTRAINT valid_order_item_total CHECK (total_price = unit_price * quantity)
);

-- Deliveries table
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    status delivery_status NOT NULL DEFAULT 'assigned',
    pickup_location POINT,
    delivery_location POINT,
    current_location POINT,
    pickup_address TEXT,
    delivery_address TEXT,
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivery_time TIMESTAMP WITH TIME ZONE,
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    distance_km DECIMAL(8,2),
    route_coordinates JSONB,
    delivery_fee DECIMAL(10,2) NOT NULL CHECK (delivery_fee >= 0),
    commission_percentage DECIMAL(5,2) DEFAULT 20.00 CHECK (commission_percentage >= 0 AND commission_percentage <= 100),
    commission_amount DECIMAL(10,2),
    platform_fee DECIMAL(10,2),
    net_earnings DECIMAL(10,2),
    customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5),
    customer_feedback TEXT,
    delivery_photo_url TEXT,
    signature_url TEXT,
    recipient_name VARCHAR(255),
    recipient_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    picked_up_at TIMESTAMP WITH TIME ZONE,
    in_transit_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES users(id),
    CONSTRAINT valid_commission_amount CHECK (commission_amount = delivery_fee * commission_percentage / 100),
    CONSTRAINT valid_net_earnings CHECK (net_earnings = commission_amount - platform_fee)
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'TZS',
    status payment_status NOT NULL DEFAULT 'pending',
    method payment_method NOT NULL,
    gateway_transaction_id VARCHAR(255),
    gateway_reference VARCHAR(255),
    gateway_response JSONB,
    gateway_provider VARCHAR(50) DEFAULT 'stripe',
    mobile_provider VARCHAR(50),
    mobile_number VARCHAR(20),
    mobile_transaction_id VARCHAR(255),
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    card_exp_month INTEGER,
    card_exp_year INTEGER,
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    transaction_reference VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,
    refund_reason TEXT,
    refund_amount DECIMAL(10,2),
    ip_address INET,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    description TEXT,
    metadata JSONB
);

-- Transactions table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type transaction_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    description TEXT NOT NULL,
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    payment_id UUID REFERENCES payments(id),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    withdrawal_method VARCHAR(50),
    withdrawal_details JSONB,
    processed_at TIMESTAMP WITH TIME ZONE,
    balance_before DECIMAL(12,2),
    balance_after DECIMAL(12,2),
    fee_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reference_number VARCHAR(255) UNIQUE,
    notes TEXT,
    metadata JSONB,
    CONSTRAINT valid_balance_change CHECK (balance_after = balance_before + amount - fee_amount - tax_amount)
);

-- Zones table - CRITICAL: This must exist before other tables reference it
CREATE TABLE zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 2000.00 CHECK (base_delivery_fee >= 0),
    fee_per_km DECIMAL(10,2) NOT NULL DEFAULT 500.00 CHECK (fee_per_km >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1 CHECK (priority >= 1),
    coverage_areas JSONB,
    center_lat DECIMAL(10,8),
    center_lng DECIMAL(11,8),
    radius_km DECIMAL(8,2),
    operating_hours JSONB DEFAULT '{"start": "06:00", "end": "22:00"}',
    delivery_time_estimate INTEGER DEFAULT 60,
    max_delivery_distance_km DECIMAL(8,2) DEFAULT 20.00,
    max_active_deliveries INTEGER DEFAULT 50,
    current_active_deliveries INTEGER DEFAULT 0,
    area_boundary GEOMETRY(POLYGON, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_radius CHECK (radius_km > 0),
    CONSTRAINT valid_capacity CHECK (current_active_deliveries <= max_active_deliveries)
);

-- Zone assignments table
CREATE TABLE zone_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    zone_id UUID NOT NULL REFERENCES zones(id),
    is_primary BOOLEAN DEFAULT FALSE,
    priority INTEGER DEFAULT 1 CHECK (priority >= 1),
    is_active BOOLEAN DEFAULT TRUE,
    assigned_by UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_deliveries INTEGER DEFAULT 0,
    successful_deliveries INTEGER DEFAULT 0,
    cancelled_deliveries INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(delivery_partner_id, zone_id)
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP WITH TIME ZONE,
    push_response JSONB,
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMP WITH TIME ZONE,
    email_response JSONB,
    sms_sent BOOLEAN DEFAULT FALSE,
    sms_sent_at TIMESTAMP WITH TIME ZONE,
    sms_response JSONB,
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    payment_id UUID REFERENCES payments(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    priority_level INTEGER DEFAULT 1 CHECK (priority_level >= 1 AND priority_level <= 5)
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    delivery_partner_id UUID REFERENCES users(id),
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    delivery_speed_rating INTEGER CHECK (delivery_speed_rating >= 1 AND delivery_speed_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    product_quality_rating INTEGER CHECK (product_quality_rating >= 1 AND product_quality_rating <= 5),
    comment TEXT,
    partner_response TEXT,
    partner_responded_at TIMESTAMP WITH TIME ZONE,
    is_public BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
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
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    bank_code VARCHAR(20),
    mobile_provider VARCHAR(50),
    mobile_number VARCHAR(20),
    mobile_account_name VARCHAR(255),
    processed_by UUID REFERENCES users(id),
    processed_at TIMESTAMP WITH TIME ZONE,
    transaction_reference VARCHAR(255),
    processing_fee DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    net_amount DECIMAL(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    rejection_reason TEXT,
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
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    assigned_to UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    resolution TEXT,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_response_at TIMESTAMP WITH TIME ZONE,
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
    applicable_users JSONB,
    applicable_zones JSONB,
    applicable_products JSONB,
    usage_limit INTEGER,
    usage_limit_per_user INTEGER,
    current_usage INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- Promotion usage table
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
-- VERIFICATION
-- =====================================================

-- Verify tables were created successfully
DO $$
DECLARE
    tables_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO tables_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    
    RAISE NOTICE '=== TABLES CREATED SUCCESSFULLY ===';
    RAISE NOTICE 'Tables created: %', tables_count;
    
    IF tables_count < 16 THEN
        RAISE EXCEPTION 'ERROR: Not all tables were created. Expected 16, got %', tables_count;
    END IF;
    
    RAISE NOTICE '✅ All tables created successfully!';
    RAISE NOTICE 'Next step: Run step2_rls_policies.sql';
END $$;
