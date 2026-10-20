import os

# Test-only signing key. Production has no default and fails startup without JWT_SECRET.
os.environ.setdefault("JWT_SECRET", "test-only-signing-secret-which-is-longer-than-forty-eight-characters")
