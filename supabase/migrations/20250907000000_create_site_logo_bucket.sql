/*
  # Create Storage Bucket for Site Logo

  This migration creates the storage bucket needed for uploading the site logo image.
  Run this if the bucket doesn't exist yet.
*/

-- Create storage bucket for site logo
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'site-logo',
  'site-logo',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
) ON CONFLICT (id) DO NOTHING;

-- Allow public read access to site logo
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public read access for site logo'
  ) THEN
    CREATE POLICY "Public read access for site logo"
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'site-logo');
  END IF;
END $$;

-- Allow public uploads (admin dashboard has its own authentication)
-- Note: In production, you may want to restrict this further
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public can upload site logo'
  ) THEN
    CREATE POLICY "Public can upload site logo"
    ON storage.objects
    FOR INSERT
    TO public
    WITH CHECK (bucket_id = 'site-logo');
  END IF;
END $$;

-- Allow public to update site logo
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public can update site logo'
  ) THEN
    CREATE POLICY "Public can update site logo"
    ON storage.objects
    FOR UPDATE
    TO public
    USING (bucket_id = 'site-logo');
  END IF;
END $$;

-- Allow public to delete site logo
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public can delete site logo'
  ) THEN
    CREATE POLICY "Public can delete site logo"
    ON storage.objects
    FOR DELETE
    TO public
    USING (bucket_id = 'site-logo');
  END IF;
END $$;
