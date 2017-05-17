require 'sqlite3'
require 'sequel'

module Linguado::Database
  class Schema
    def create_database
      DB.create_table? :courses do
        primary_key :id
        String :name, null: false
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :words do
        primary_key :id
        foreign_key :course_id, :courses
        String :name, null: false
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :questions do
        primary_key :id
        foreign_key :course_id, :courses
        String :type, null: false
        String :question, null: false
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :lessons do
        primary_key :id
        foreign_key :course_id, :courses
        String :name, null: false
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :question_exercises do
        primary_key :id
        foreign_key :question_id, :questions
        TrueClass :correct, default: true
        String :answer
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :word_exercises do
        primary_key :id
        foreign_key :word_id, :words
        TrueClass :correct, default: true 
        String :mistaken_with
        DateTime :created_at

        index :created_at
      end

      DB.create_table? :lesson_exercises do
        primary_key :id
        foreign_key :lesson_id, :lessons
        Number :questions, default: 0
        Number :correct_answers, default: 0
        DateTime :created_at

        index :created_at
      end
    end
  end
end
