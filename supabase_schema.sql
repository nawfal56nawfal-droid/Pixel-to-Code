-- ============================================================
-- Supabase Database Schema for DevPortfolio App
-- Run this script in the Supabase SQL Editor
-- URL: https://arezfwbxslzvbhkvbnql.supabase.co
-- ============================================================

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    download_url TEXT,
    platform_type TEXT DEFAULT 'Android', -- e.g. 'Android', 'Web', 'iOS', 'Cross-Platform'
    current_version TEXT DEFAULT 'v1.0.0',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create updates table (Changelogs)
CREATE TABLE IF NOT EXISTS updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    version TEXT NOT NULL,
    changelog_text TEXT NOT NULL,
    release_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for fast queries on project updates
CREATE INDEX IF NOT EXISTS idx_updates_project_id ON updates(project_id);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE updates ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies: Public Read Access (Anyone can view projects & updates)
DROP POLICY IF EXISTS "Public projects are viewable by everyone" ON projects;
CREATE POLICY "Public projects are viewable by everyone" 
    ON projects FOR SELECT 
    USING (true);

DROP POLICY IF EXISTS "Public updates are viewable by everyone" ON updates;
CREATE POLICY "Public updates are viewable by everyone" 
    ON updates FOR SELECT 
    USING (true);

-- 5. RLS Policies: Admin Authenticated Access (Only logged-in Admin can insert/update/delete)
DROP POLICY IF EXISTS "Admin can insert projects" ON projects;
CREATE POLICY "Admin can insert projects" 
    ON projects FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin can update projects" ON projects;
CREATE POLICY "Admin can update projects" 
    ON projects FOR UPDATE 
    USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin can delete projects" ON projects;
CREATE POLICY "Admin can delete projects" 
    ON projects FOR DELETE 
    USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin can insert updates" ON updates;
CREATE POLICY "Admin can insert updates" 
    ON updates FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin can update updates" ON updates;
CREATE POLICY "Admin can update updates" 
    ON updates FOR UPDATE 
    USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin can delete updates" ON updates;
CREATE POLICY "Admin can delete updates" 
    ON updates FOR DELETE 
    USING (auth.role() = 'authenticated');

-- ============================================================
-- OPTIONAL: Create Admin User directly via SQL
-- Email: admin@devportfolio.com
-- Password: Admin123456!
-- ============================================================
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) 
SELECT 
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@devportfolio.com',
    crypt('Admin123456!', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
WHERE NOT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@devportfolio.com'
);
