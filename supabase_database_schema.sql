-- Water Delivery App Database Schema for Supabase
-- URL: https://fnqrpyidgshgrwseyvsu.supabase.co

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
CREATE TYPE user_role AS ENUM ('customer', 'delivery', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('cash', 'mobile_money', 'card', 'bank_transfer');
CREATE TYPE delivery_status AS ENUM ('assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled');
CREATE TYPE notification_type AS ENUM ('order_update', 'delivery_update', 'payment', 'system', 'promotion');

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
    
    -- Delivery partner specific fields
    vehicle_type VARCHAR(50),
    license_plate VARCHAR(20),
    vehicle_registration VARCHAR(50),
    is_online BOOLEAN DEFAULT FALSE,
    current_location POINT,
    delivery_rating DECIMAL(3,2) DEFAULT 0.00,
    total_deliveries INTEGER DEFAULT 0,
    
    -- Admin specific fields
    permissions TEXT[] DEFAULT ARRAY[]::integer[]
);

-- Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL DEFAULT 'home', -- home, office, other
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    street TEXT NOT NULL,
    area VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL DEFAULT 'Dar es Salaam',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_address_type CHECK (type IN ('home', 'office', 'other'))
);

-- Water types table
CREATE TABLE water_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    volume_liters INTEGER NOT NULL,
    bottle_type VARCHAR(50), -- plastic, glass, reusable
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES users(id),
    status order_status NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    
    -- Delivery information
    delivery_address_id UUID NOT NULL REFERENCES addresses(id),
    delivery_instructions TEXT,
    preferred_delivery_time TIMESTAMP WITH TIME ZONE,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    
    -- Payment information
    payment_status payment_status NOT NULL DEFAULT 'pending',
    payment_method payment_method,
    payment_reference VARCHAR(255),
    paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Delivery partner
    delivery_partner_id UUID REFERENCES users(id),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    preparing_at TIMESTAMP WITH TIME ZONE,
    out_for_delivery_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    
    -- Metadata
    source VARCHAR(50) DEFAULT 'mobile_app', -- mobile_app, web, admin
    notes TEXT
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    water_type_id UUID NOT NULL REFERENCES water_types(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Deliveries table
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    status delivery_status NOT NULL DEFAULT 'assigned',
    
    -- Location tracking
    pickup_location POINT,
    delivery_location POINT,
    current_location POINT,
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivery_time TIMESTAMP WITH TIME ZONE,
    
    -- Distance and time
    distance_km DECIMAL(8,2),
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    
    -- Earnings
    delivery_fee DECIMAL(10,2) NOT NULL,
    commission_percentage DECIMAL(5,2) DEFAULT 20.00,
    commission_amount DECIMAL(10,2),
    platform_fee DECIMAL(10,2),
    net_earnings DECIMAL(10,2),
    
    -- Customer feedback
    customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5),
    customer_feedback TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    picked_up_at TIMESTAMP WITH TIME ZONE,
    in_transit_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    status payment_status NOT NULL DEFAULT 'pending',
    method payment_method NOT NULL,
    
    -- Payment gateway details
    gateway_transaction_id VARCHAR(255),
    gateway_reference VARCHAR(255),
    gateway_response JSONB,
    
    -- Mobile money specific
    mobile_provider VARCHAR(50), -- M-Pesa, Tigo Pesa, Airtel Money, etc.
    mobile_number VARCHAR(20),
    
    -- Card specific
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    
    -- Bank transfer specific
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    transaction_reference VARCHAR(255),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    failed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,
    
    -- Metadata
    ip_address INET,
    user_agent TEXT
);

-- Transactions table (for delivery partner earnings and withdrawals)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(20) NOT NULL, -- earning, withdrawal, bonus, penalty
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TZS',
    description TEXT NOT NULL,
    
    -- Related entities
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed, cancelled
    
    -- Withdrawal specific
    withdrawal_method VARCHAR(50), -- bank_transfer, mobile_money
    withdrawal_details JSONB,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadata
    reference_number VARCHAR(255),
    notes TEXT
);

-- Zones table (for delivery area management)
CREATE TABLE zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    area_boundary GEOMETRY(POLYGON, 4326) NOT NULL, -- Using PostGIS for geographic boundaries
    base_delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 2000.00,
    fee_per_km DECIMAL(10,2) NOT NULL DEFAULT 500.00,
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1, -- Lower number = higher priority
    
    -- Coverage
    coverage_areas JSONB, -- Array of area names within this zone
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Zone assignments (delivery partners to zones)
CREATE TABLE zone_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delivery_partner_id UUID NOT NULL REFERENCES users(id),
    zone_id UUID NOT NULL REFERENCES zones(id),
    is_primary BOOLEAN DEFAULT FALSE, -- Primary zone for this partner
    priority INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
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
    data JSONB, -- Additional data payload
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Push notification
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP WITH TIME ZONE,
    push_response JSONB,
    
    -- Related entities
    order_id UUID REFERENCES orders(id),
    delivery_id UUID REFERENCES deliveries(id),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Expiration
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Reviews table
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
    
    -- Status
    is_public BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE, -- Verified by admin
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_current_location ON users USING GIST(current_location);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_is_default ON addresses(is_default);
CREATE INDEX idx_addresses_location ON addresses USING GIST(ST_MakePoint(longitude, latitude));

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_delivery_partner_id ON orders(delivery_partner_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_water_type_id ON order_items(water_type_id);

CREATE INDEX idx_deliveries_order_id ON deliveries(order_id);
CREATE INDEX idx_deliveries_delivery_partner_id ON deliveries(delivery_partner_id);
CREATE INDEX idx_deliveries_status ON deliveries(status);
CREATE INDEX idx_deliveries_created_at ON deliveries(created_at);
CREATE INDEX idx_deliveries_current_location ON deliveries USING GIST(current_location);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_method ON payments(method);
CREATE INDEX idx_payments_created_at ON payments(created_at);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_delivery_partner_id ON reviews(delivery_partner_id);
CREATE INDEX idx_reviews_overall_rating ON reviews(overall_rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

CREATE INDEX idx_zones_is_active ON zones(is_active);
CREATE INDEX idx_zones_priority ON zones(priority);
CREATE INDEX idx_zones_area_boundary ON zones USING GIST(area_boundary);

CREATE INDEX idx_zone_assignments_delivery_partner_id ON zone_assignments(delivery_partner_id);
CREATE INDEX idx_zone_assignments_zone_id ON zone_assignments(zone_id);
CREATE INDEX idx_zone_assignments_is_active ON zone_assignments(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
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

-- Create function to generate order numbers
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

-- Insert default water types
INSERT INTO water_types (name, description, price, volume_liters, bottle_type) VALUES
('Standard Purified Water', '20L bottle of purified drinking water', 5000.00, 20, 'plastic'),
('Mineral Water', '20L bottle of natural mineral water', 7000.00, 20, 'plastic'),
('Spring Water', '20L bottle of spring water', 6500.00, 20, 'plastic'),
('Alkaline Water', '20L bottle of alkaline water', 8000.00, 20, 'plastic'),
('Glass Bottled Water', '19L glass bottle of premium water', 12000.00, 19, 'glass');

-- Create default zones for Dar es Salaam (example zones)
INSERT INTO zones (name, description, base_delivery_fee, fee_per_km, area_boundary, coverage_areas) VALUES
('City Center', 'Central business district and surrounding areas', 2000.00, 500.00, 
 ST_GeomFromText('POLYGON((39.2083 -6.7924, 39.2183 -6.7924, 39.2183 -6.7824, 39.2083 -6.7824, 39.2083 -6.7924))', 4326),
 '["Kivukoni", "Kariakoo", "Mchikichini", "Upanga"]'),
('Oysterbay', 'Upscale residential and commercial area', 3000.00, 600.00,
 ST_GeomFromText('POLYGON((39.2833 -6.7624, 39.2933 -6.7624, 39.2933 -6.7524, 39.2833 -6.7524, 39.2833 -6.7624))', 4326),
 '["Oysterbay", "Masaki", "Regent Estate", "Mikocheni"]'),
('Kinondoni', 'Major residential and commercial hub', 2500.00, 550.00,
 ST_GeomFromText('POLYGON((39.1833 -6.8224, 39.1933 -6.8224, 39.1933 -6.8124, 39.1833 -6.8124, 39.1833 -6.8224))', 4326),
 '["Kinondoni", "Hananasif", "Mwenge", "Kijitonyama"]'),
('Mikocheni', 'Mixed residential and commercial area', 2800.00, 580.00,
 ST_GeomFromText('POLYGON((39.2333 -6.7724, 39.2433 -6.7724, 39.2433 -6.7624, 39.2333 -6.7624, 39.2333 -6.7724))', 4326),
 '["Mikocheni A", "Mikocheni B", "Regent Estate", "Ada Estate"]');
