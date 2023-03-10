package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"

	"github.com/tabo-syu/bookmarks/infrastructures"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("migration failed: %s", err.Error())
	}

	log.Print("migration succeeded!")
}

func run() error {
	db, err := infrastructures.NewSQLHandler()
	if err != nil {
		return err
	}
	defer db.Close()

	wd, err := os.Getwd()
	if err != nil {
		return err
	}

	schema, err := os.Open(filepath.Join(wd, "sqlc", "schema.sql"))
	if err != nil {
		return err
	}
	defer schema.Close()

	initializeQuery := "drop schema public cascade; create schema public;"
	migrationQuery, err := io.ReadAll(schema)
	if err != nil {
		return err
	}
	query := fmt.Sprintf("%s%s", initializeQuery, migrationQuery)

	_, err = db.ExecContext(context.Background(), query)
	if err != nil {
		return err
	}

	return nil
}
