package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"

	"cloud.google.com/go/compute/metadata"
	"google.golang.org/api/idtoken"
)

func audience() (string, error) {
	projectNumber, err := metadata.NumericProjectID()
	if err != nil {
			return "", fmt.Errorf("metadata.NumericProjectID: %w", err)
	}

	projectID, err := metadata.ProjectID()
	if err != nil {
			return "", fmt.Errorf("metadata.ProjectID: %w", err)
	}

	return "/projects/" + projectNumber + "/apps/" + projectID, nil
}

func AuthenticationMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		assertion := r.Header.Get("X-Goog-IAP-JWT-Assertion")
		if assertion == "" {
				log.Println("No Cloud IAP header found.")
				http.Error(w, "Forbidden", http.StatusForbidden)
				return
		}
		err := validateJWTFromAppEngine(w, assertion, )
		if err != nil {
				log.Println(err)
				http.Error(w, "Forbidden", http.StatusForbidden)
				return
		}
		next.ServeHTTP(w, r)
    })
}

func validateJWTFromAppEngine(w io.Writer, iapJWT string) error {
	ctx := context.Background()

	aud, err := audience()
	if err != nil {
		return err
	}

	payload, err := idtoken.Validate(ctx, iapJWT, aud)
	if err != nil {
			return fmt.Errorf("idtoken.Validate: %w", err)
	}

	// payload contains the JWT claims for further inspection or validation
	fmt.Fprintf(w, "payload: %v", payload)

	return nil
}