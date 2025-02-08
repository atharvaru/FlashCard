/*
  # Create sets table and update flashcards schema

  1. New Tables
    - `sets`
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `description` (text)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)

  2. Changes to Existing Tables
    - Add `set_id` column to `flashcards` table
    - Add foreign key constraint to link flashcards to sets

  3. Security
    - Enable RLS on `sets` table
    - Add policies for users to manage their own sets
*/

-- Create sets table
CREATE TABLE IF NOT EXISTS sets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL CHECK (char_length(trim(name)) > 0),
    description text,
    user_id uuid REFERENCES auth.users NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Add set_id to flashcards
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'flashcards' AND column_name = 'set_id'
    ) THEN
        ALTER TABLE flashcards 
        ADD COLUMN set_id uuid REFERENCES sets(id);
    END IF;
END $$;

-- Enable RLS
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;

-- Policies for sets
CREATE POLICY "Users can view their own sets"
    ON sets
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own sets"
    ON sets
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sets"
    ON sets
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sets"
    ON sets
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Update flashcards policies to include set_id checks
DROP POLICY IF EXISTS "Users can view their own flashcards" ON flashcards;
CREATE POLICY "Users can view their own flashcards"
    ON flashcards
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create flashcards" ON flashcards;
CREATE POLICY "Users can create flashcards"
    ON flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id AND
        (set_id IS NULL OR EXISTS (
            SELECT 1 FROM sets WHERE id = set_id AND user_id = auth.uid()
        ))
    );