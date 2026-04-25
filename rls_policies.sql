-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Water Delivery App - Clean Database
-- URL: https://fqvdqspdqyfeblxgjozz.supabase.co
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
-- SECURITY FUNCTIONS
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

-- Function to check if user can access specific order
CREATE OR REPLACE FUNCTION can_access_order(order_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM orders 
        WHERE id = order_uuid AND 
        (customer_id = auth.uid() OR delivery_partner_id = auth.uid() OR user_is_admin())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile (except role and critical fields)
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (
        auth.uid() = id AND 
        role = old.role AND
        is_active = old.is_active AND
        is_verified = old.is_verified
    );

-- Admins can view all users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (user_is_admin());

-- Admins can update all users
CREATE POLICY "Admins can update all users" ON users
    FOR UPDATE USING (user_is_admin());

-- Service role can insert users (for registration)
CREATE POLICY "Service can insert users" ON users
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- ADDRESSES TABLE POLICIES
-- =====================================================

-- Users can view their own addresses
CREATE POLICY "Users can view own addresses" ON addresses
    FOR SELECT USING (user_id = auth.uid());

-- Users can insert their own addresses
CREATE POLICY "Users can insert own addresses" ON addresses
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Users can update their own addresses
CREATE POLICY "Users can update own addresses" ON addresses
    FOR UPDATE USING (user_id = auth.uid());

-- Users can delete their own addresses
CREATE POLICY "Users can delete own addresses" ON addresses
    FOR DELETE USING (user_id = auth.uid());

-- Admins can view all addresses
CREATE POLICY "Admins can view all addresses" ON addresses
    FOR SELECT USING (user_is_admin());

-- =====================================================
-- WATER TYPES TABLE POLICIES
-- =====================================================

-- Authenticated users can view active water types
CREATE POLICY "Authenticated users can view water types" ON water_types
    FOR SELECT USING (is_active = true AND auth.role() = 'authenticated');

-- Admins can manage water types
CREATE POLICY "Admins can manage water types" ON water_types
    FOR ALL USING (user_is_admin());

-- =====================================================
-- ORDERS TABLE POLICIES
-- =====================================================

-- Customers can view their own orders
CREATE POLICY "Customers can view own orders" ON orders
    FOR SELECT USING (customer_id = auth.uid());

-- Delivery partners can view orders assigned to them
CREATE POLICY "Delivery partners can view assigned orders" ON orders
    FOR SELECT USING (delivery_partner_id = auth.uid());

-- Admins can view all orders
CREATE POLICY "Admins can view all orders" ON orders
    FOR SELECT USING (user_is_admin());

-- Customers can insert their own orders
CREATE POLICY "Customers can insert own orders" ON orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());

-- Delivery partners can update order status for assigned orders
CREATE POLICY "Delivery partners can update assigned orders" ON orders
    FOR UPDATE USING (
        delivery_partner_id = auth.uid() AND
        status IN ('out_for_delivery', 'delivered')
    );

-- Admins can update all orders
CREATE POLICY "Admins can update all orders" ON orders
    FOR UPDATE USING (user_is_admin());

-- =====================================================
-- ORDER ITEMS TABLE POLICIES
-- =====================================================

-- Users can view order items for their own orders
CREATE POLICY "Users can view own order items" ON order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = order_items.order_id AND 
            (customer_id = auth.uid() OR delivery_partner_id = auth.uid() OR user_is_admin())
        )
    );

-- Service role can manage order items
CREATE POLICY "Service can manage order items" ON order_items
    FOR ALL WITH CHECK (true);

-- =====================================================
-- DELIVERIES TABLE POLICIES
-- =====================================================

-- Delivery partners can view their own deliveries
CREATE POLICY "Delivery partners can view own deliveries" ON deliveries
    FOR SELECT USING (delivery_partner_id = auth.uid());

-- Customers can view deliveries for their orders
CREATE POLICY "Customers can view own deliveries" ON deliveries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = deliveries.order_id AND customer_id = auth.uid()
        )
    );

-- Admins can view all deliveries
CREATE POLICY "Admins can view all deliveries" ON deliveries
    FOR SELECT USING (user_is_admin());

-- Delivery partners can update their own deliveries
CREATE POLICY "Delivery partners can update own deliveries" ON deliveries
    FOR UPDATE USING (delivery_partner_id = auth.uid());

-- Admins can update all deliveries
CREATE POLICY "Admins can update all deliveries" ON deliveries
    FOR UPDATE USING (user_is_admin());

-- Service role can insert deliveries
CREATE POLICY "Service can insert deliveries" ON deliveries
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- PAYMENTS TABLE POLICIES
-- =====================================================

-- Customers can view payments for their own orders
CREATE POLICY "Customers can view own payments" ON payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = payments.order_id AND customer_id = auth.uid()
        )
    );

-- Admins can view all payments
CREATE POLICY "Admins can view all payments" ON payments
    FOR SELECT USING (user_is_admin());

-- Service role can manage payments
CREATE POLICY "Service can manage payments" ON payments
    FOR ALL WITH CHECK (true);

-- =====================================================
-- TRANSACTIONS TABLE POLICIES
-- =====================================================

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (user_id = auth.uid());

-- Users can insert withdrawal requests
CREATE POLICY "Users can insert withdrawal requests" ON transactions
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND 
        type = 'withdrawal'
    );

-- Admins can view all transactions
CREATE POLICY "Admins can view all transactions" ON transactions
    FOR SELECT USING (user_is_admin());

-- Admins can update all transactions
CREATE POLICY "Admins can update all transactions" ON transactions
    FOR UPDATE USING (user_is_admin());

-- Service role can insert earnings and bonuses
CREATE POLICY "Service can insert earnings" ON transactions
    FOR INSERT WITH CHECK (
        type IN ('earning', 'bonus', 'penalty', 'commission')
    );

-- =====================================================
-- ZONES TABLE POLICIES
-- =====================================================

-- Authenticated users can view active zones
CREATE POLICY "Authenticated users can view zones" ON zones
    FOR SELECT USING (is_active = true AND auth.role() = 'authenticated');

-- Admins can manage zones
CREATE POLICY "Admins can manage zones" ON zones
    FOR ALL USING (user_is_admin());

-- =====================================================
-- ZONE ASSIGNMENTS TABLE POLICIES
-- =====================================================

-- Delivery partners can view their own zone assignments
CREATE POLICY "Delivery partners can view own zone assignments" ON zone_assignments
    FOR SELECT USING (delivery_partner_id = auth.uid());

-- Admins can view all zone assignments
CREATE POLICY "Admins can view all zone assignments" ON zone_assignments
    FOR SELECT USING (user_is_admin());

-- Admins can manage zone assignments
CREATE POLICY "Admins can manage zone assignments" ON zone_assignments
    FOR ALL USING (user_is_admin());

-- Service role can manage zone assignments
CREATE POLICY "Service can manage zone assignments" ON zone_assignments
    FOR ALL WITH CHECK (true);

-- =====================================================
-- NOTIFICATIONS TABLE POLICIES
-- =====================================================

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- Service role can manage notifications
CREATE POLICY "Service can manage notifications" ON notifications
    FOR ALL WITH CHECK (true);

-- =====================================================
-- REVIEWS TABLE POLICIES
-- =====================================================

-- Users can view public reviews
CREATE POLICY "Users can view public reviews" ON reviews
    FOR SELECT USING (is_public = true);

-- Customers can view reviews for their own orders
CREATE POLICY "Customers can view own reviews" ON reviews
    FOR SELECT USING (customer_id = auth.uid());

-- Delivery partners can view reviews for their deliveries
CREATE POLICY "Delivery partners can view own reviews" ON reviews
    FOR SELECT USING (delivery_partner_id = auth.uid());

-- Admins can view all reviews
CREATE POLICY "Admins can view all reviews" ON reviews
    FOR SELECT USING (user_is_admin());

-- Customers can insert reviews for their completed orders
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

-- Customers can update their own reviews
CREATE POLICY "Customers can update own reviews" ON reviews
    FOR UPDATE USING (customer_id = auth.uid());

-- Delivery partners can respond to reviews
CREATE POLICY "Delivery partners can respond to reviews" ON reviews
    FOR UPDATE USING (
        delivery_partner_id = auth.uid() AND
        partner_response IS NOT NULL
    );

-- Admins can update all reviews
CREATE POLICY "Admins can update all reviews" ON reviews
    FOR UPDATE USING (user_is_admin());

-- =====================================================
-- WITHDRAWAL REQUESTS TABLE POLICIES
-- =====================================================

-- Users can view their own withdrawal requests
CREATE POLICY "Users can view own withdrawal requests" ON withdrawal_requests
    FOR SELECT USING (user_id = auth.uid());

-- Users can insert withdrawal requests
CREATE POLICY "Users can insert withdrawal requests" ON withdrawal_requests
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Admins can view all withdrawal requests
CREATE POLICY "Admins can view all withdrawal requests" ON withdrawal_requests
    FOR SELECT USING (user_is_admin());

-- Admins can update all withdrawal requests
CREATE POLICY "Admins can update all withdrawal requests" ON withdrawal_requests
    FOR UPDATE USING (user_is_admin());

-- =====================================================
-- SUPPORT TICKETS TABLE POLICIES
-- =====================================================

-- Users can view their own support tickets
CREATE POLICY "Users can view own support tickets" ON support_tickets
    FOR SELECT USING (user_id = auth.uid());

-- Users can insert support tickets
CREATE POLICY "Users can insert support tickets" ON support_tickets
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Users can update their own support tickets
CREATE POLICY "Users can update own support tickets" ON support_tickets
    FOR UPDATE USING (user_id = auth.uid());

-- Admins can view all support tickets
CREATE POLICY "Admins can view all support tickets" ON support_tickets
    FOR SELECT USING (user_is_admin());

-- Admins can update all support tickets
CREATE POLICY "Admins can update all support tickets" ON support_tickets
    FOR UPDATE USING (user_is_admin());

-- =====================================================
-- PROMOTIONS TABLE POLICIES
-- =====================================================

-- Authenticated users can view active promotions
CREATE POLICY "Authenticated users can view promotions" ON promotions
    FOR SELECT USING (
        is_active = true AND 
        auth.role() = 'authenticated' AND
        (starts_at IS NULL OR starts_at <= NOW()) AND
        (expires_at IS NULL OR expires_at > NOW())
    );

-- Admins can manage promotions
CREATE POLICY "Admins can manage promotions" ON promotions
    FOR ALL USING (user_is_admin());

-- =====================================================
-- PROMOTION USAGE TABLE POLICIES
-- =====================================================

-- Users can view their own promotion usage
CREATE POLICY "Users can view own promotion usage" ON promotion_usage
    FOR SELECT USING (user_id = auth.uid());

-- Service role can manage promotion usage
CREATE POLICY "Service can manage promotion usage" ON promotion_usage
    FOR ALL WITH CHECK (true);

-- =====================================================
-- PERMISSIONS AND GRANTS
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

-- Grant read-only permissions to anonymous users (for public data)
GRANT SELECT ON water_types TO anon;
GRANT SELECT ON zones TO anon;
GRANT SELECT ON promotions TO anon;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Create view for delivery partner earnings
CREATE OR REPLACE VIEW delivery_partner_earnings AS
SELECT 
    u.id as delivery_partner_id,
    u.name as delivery_partner_name,
    u.phone as delivery_partner_phone,
    u.email as delivery_partner_email,
    COALESCE(SUM(CASE WHEN t.type = 'earning' THEN t.amount ELSE 0 END), 0) as total_earnings,
    COALESCE(SUM(CASE WHEN t.type = 'withdrawal' THEN t.amount ELSE 0 END), 0) as total_withdrawals,
    COALESCE(SUM(CASE WHEN t.type = 'bonus' THEN t.amount ELSE 0 END), 0) as total_bonuses,
    COALESCE(SUM(CASE WHEN t.type = 'penalty' THEN t.amount ELSE 0 END), 0) as total_penalties,
    (COALESCE(SUM(CASE WHEN t.type = 'earning' THEN t.amount ELSE 0 END), 0) - 
     COALESCE(SUM(CASE WHEN t.type = 'withdrawal' THEN t.amount ELSE 0 END), 0) +
     COALESCE(SUM(CASE WHEN t.type = 'bonus' THEN t.amount ELSE 0 END), 0) -
     COALESCE(SUM(CASE WHEN t.type = 'penalty' THEN t.amount ELSE 0 END), 0)) as available_balance,
    COUNT(CASE WHEN d.status = 'delivered' THEN 1 END) as completed_deliveries,
    AVG(r.overall_rating) as average_rating,
    u.is_online,
    u.vehicle_type,
    u.delivery_rating
FROM users u
LEFT JOIN transactions t ON u.id = t.user_id
LEFT JOIN deliveries d ON u.id = d.delivery_partner_id
LEFT JOIN reviews r ON u.id = r.delivery_partner_id
WHERE u.role = 'delivery' AND u.is_active = true
GROUP BY u.id, u.name, u.phone, u.email, u.is_online, u.vehicle_type, u.delivery_rating;

-- Grant access to earnings view
GRANT SELECT ON delivery_partner_earnings TO authenticated;
GRANT SELECT ON delivery_partner_earnings TO service_role;

-- Create RLS policy for earnings view
ALTER VIEW delivery_partner_earnings SET (security_barrier = true);

CREATE POLICY "Delivery partners can view own earnings" ON delivery_partner_earnings
    FOR SELECT USING (delivery_partner_id = auth.uid());

CREATE POLICY "Admins can view all earnings" ON delivery_partner_earnings
    FOR SELECT USING (user_is_admin());

-- Create view for order statistics
CREATE OR REPLACE VIEW order_statistics AS
SELECT 
    DATE_TRUNC('day', created_at) as order_date,
    COUNT(*) as total_orders,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered_orders,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value
FROM orders
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY order_date DESC;

-- Grant access to order statistics
GRANT SELECT ON order_statistics TO authenticated;
GRANT SELECT ON order_statistics TO service_role;

-- Create RLS policy for order statistics
ALTER VIEW order_statistics SET (security_barrier = true);

CREATE POLICY "Admins can view order statistics" ON order_statistics
    FOR SELECT USING (user_is_admin());

-- =====================================================
-- AUDIT TRIGGERS
-- =====================================================

-- Create audit trigger for sensitive operations
CREATE OR REPLACE FUNCTION audit_sensitive_operations()
RETURNS TRIGGER AS $$
BEGIN
    -- Log changes to user roles and critical fields
    IF TG_TABLE_NAME = 'users' AND (
        OLD.role IS DISTINCT FROM NEW.role OR
        OLD.is_active IS DISTINCT FROM NEW.is_active OR
        OLD.is_verified IS DISTINCT FROM NEW.is_verified
    ) THEN
        INSERT INTO notifications (
            user_id, 
            type, 
            title, 
            message, 
            data
        ) VALUES (
            NEW.id,
            'system',
            'Account Status Changed',
            'Your account status has been updated',
            jsonb_build_object(
                'old_role', OLD.role,
                'new_role', NEW.role,
                'old_is_active', OLD.is_active,
                'new_is_active', NEW.is_active,
                'old_is_verified', OLD.is_verified,
                'new_is_verified', NEW.is_verified
            )
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create audit trigger
CREATE TRIGGER audit_user_changes
    AFTER UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_sensitive_operations();
