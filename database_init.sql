-- =====================================================
-- DATABASE INITIALIZATION SCRIPT
-- Water Delivery App - Essential Data Only
-- URL: https://fqvdqspdqyfeblxgjozz.supabase.co
-- NO SAMPLE DATA - Clean Production Setup
-- =====================================================

-- This script contains only essential data needed for the app to function
-- Run this AFTER database_schema.sql and rls_policies.sql

-- =====================================================
-- ESSENTIAL WATER TYPES (Minimum Required)
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

-- =====================================================
-- ESSENTIAL DELIVERY ZONES (Dar es Salaam Coverage)
-- =====================================================

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

-- =====================================================
-- SYSTEM ADMIN USER (Required for Admin Operations)
-- =====================================================

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
-- DEFAULT PROMOTIONS (Optional - Can be Added Later)
-- =====================================================

-- Comment out promotions for now - add when needed
/*
INSERT INTO promotions (
    name,
    description,
    code,
    type,
    value,
    min_order_amount,
    max_discount_amount,
    is_active,
    starts_at,
    expires_at,
    created_by
) VALUES
(
    'Welcome Discount',
    'First order discount for new customers',
    'WELCOME10',
    'percentage',
    10.00,
    5000.00,
    2000.00,
    true,
    NOW(),
    NOW() + INTERVAL '90 days',
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
);
*/

-- =====================================================
-- VERIFICATION AND COMPLETION
-- =====================================================

-- Verify essential data was inserted
DO $$
DECLARE
    water_types_count INTEGER;
    zones_count INTEGER;
    admin_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO water_types_count FROM water_types WHERE is_active = true;
    SELECT COUNT(*) INTO zones_count FROM zones WHERE is_active = true;
    SELECT COUNT(*) INTO admin_count FROM users WHERE role = 'admin';
    
    RAISE NOTICE 'Database initialization completed:';
    RAISE NOTICE '- Water types: %', water_types_count;
    RAISE NOTICE '- Active zones: %', zones_count;
    RAISE NOTICE '- Admin users: %', admin_count;
    
    IF water_types_count = 0 THEN
        RAISE EXCEPTION 'No water types found - app will not function properly';
    END IF;
    
    IF zones_count = 0 THEN
        RAISE EXCEPTION 'No zones found - delivery operations will fail';
    END IF;
    
    IF admin_count = 0 THEN
        RAISE EXCEPTION 'No admin users found - system management will be limited';
    END IF;
END $$;

-- =====================================================
-- SETUP COMPLETE
-- =====================================================

-- Database is now ready for production use
-- Next steps:
-- 1. Set admin password through Supabase Auth
-- 2. Configure storage buckets if needed
-- 3. Set up any additional business logic
-- 4. Test the application thoroughly
