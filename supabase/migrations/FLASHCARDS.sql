/*
  # Flashcards Schema Setup

  1. New Tables
    - `flashcards`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `front` (text, card front content)
      - `back` (text, card back content)
      - `created_at` (timestamp)
      - `last_reviewed` (timestamp)
      
  2. Security
    - Enable RLS on `flashcards` table
    - Add policies for CRUD operations
*/

CREATE TABLE IF NOT EXISTS flashcards (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users NOT NULL,
    front text NOT NULL,
    back text NOT NULL,
    created_at timestamptz DEFAULT now(),
    last_reviewed timestamptz,
    CONSTRAINT front_not_empty CHECK (front <> ''),
    CONSTRAINT back_not_empty CHECK (back <> '')
);

ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own flashcards
CREATE POLICY "Users can view their own flashcards"
    ON flashcards
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Allow users to create their own flashcards
CREATE POLICY "Users can create flashcards"
    ON flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own flashcards
CREATE POLICY "Users can update their own flashcards"
    ON flashcards
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own flashcards
CREATE POLICY "Users can delete their own flashcards"
    ON flashcards
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);