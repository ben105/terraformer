# Authenticating Users with Go

## Validate Assertion

The validateAssertion function validates the assertion was properly signed and returns the associated email address and user ID.

Validating a JWT assertion requires knowing the public key certificates of the entity that signed the assertion (Google in this case), and the audience the assertion is intended for. For an App Engine app, the audience is a string with Google Cloud project identification information in it. The validateAssertion function gets those certificates from the certs function and the audience string from the audience function.

```go
// validateAssertion validates assertion was signed by Google and returns the
// associated email and userID.
func validateAssertion(assertion string, certs map[string]string, aud string) (email string, userID string, err error) {
        token, err := jwt.Parse(assertion, func(token *jwt.Token) (interface{}, error) {
                keyID := token.Header["kid"].(string)

                _, ok := token.Method.(*jwt.SigningMethodECDSA)
                if !ok {
                        return nil, fmt.Errorf("unexpected signing method: %q", token.Header["alg"])
                }

                cert := certs[keyID]
                return jwt.ParseECPublicKeyFromPEM([]byte(cert))
        })

        if err != nil {
                return "", "", err
        }

        claims, ok := token.Claims.(jwt.MapClaims)
        if !ok {
                return "", "", fmt.Errorf("could not extract claims (%T): %+v", token.Claims, token.Claims)
        }

        if claims["aud"].(string) != aud {
                return "", "", fmt.Errorf("mismatched audience. aud field %q does not match %q", claims["aud"], aud)
        }
        return claims["email"].(string), claims["sub"].(string), nil
}
```

### Get the certificates
```go
// certificates returns Cloud IAP's cryptographic public keys.
func certificates() (map[string]string, error) {
        const url = "https://www.gstatic.com/iap/verify/public_key"
        client := http.Client{
                Timeout: 5 * time.Second,
        }
        resp, err := client.Get(url)
        if err != nil {
                return nil, fmt.Errorf("Get: %w", err)
        }

        var certs map[string]string
        dec := json.NewDecoder(resp.Body)
        if err := dec.Decode(&certs); err != nil {
                return nil, fmt.Errorf("Decode: %w", err)
        }

        return certs, nil
}
```

### Get the audience
```go
// audience returns the expected audience value for this service.
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
```

### Example

The index function gets the JWT assertion header value that IAP added from the incoming request and calls the validateAssertion function to validate the cryptographically signed value. The email address is then used in a minimal web response.

```go
// index responds to requests with our greeting.
func (a *app) index(w http.ResponseWriter, r *http.Request) {
        if r.URL.Path != "/" {
                http.NotFound(w, r)
                return
        }

        assertion := r.Header.Get("X-Goog-IAP-JWT-Assertion")
        if assertion == "" {
                fmt.Fprintln(w, "No Cloud IAP header found.")
                return
        }
        email, _, err := validateAssertion(assertion, a.certs, a.aud)
        if err != nil {
                log.Println(err)
                fmt.Fprintln(w, "Could not validate assertion. Check app logs.")
                return
        }

        fmt.Fprintf(w, "Hello %s\n", email)
}
```
