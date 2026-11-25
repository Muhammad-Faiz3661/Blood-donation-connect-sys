# Pulse blood donation connect

A Flutter app with separate donor and recipient portals. Recipients can find
available donor profiles by blood group and area, send requests, and track
responses. Donors can manage availability, accept or decline requests, and
mark donations complete.

## Contributors

- Haider Naeem
- Faizullah

## Run

Install the Flutter SDK, then from the project root run:

```sh
flutter pub get
flutter run
```

## App flows

- Create a donor or recipient profile with a blood group, phone number, city or
  area, and a password. Each profile receives a unique account ID; find it on
  the Profile tab and use it with the password to log in after signing out.
- View profile information in a dedicated, redesigned Profile tab with a
  profile header, blood group badge, personal-detail cards, and account ID
  copy option.
- Switch or log out of the current account from the Profile tab. The account
  ID can be copied directly for future login.
- Existing profiles created before password login was added set a password on
  their first login.
- Search available donor profiles by blood group and location.
- Send a request with a hospital or clinic and optional note.
- Accepting a request reveals contact details to the two profiles involved.
- Donors can pause or resume appearing in searches; recipients can cancel
	pending requests.
- Switch or add profiles from the Profile tab to try both portals on one
	device.

## Data and safety

This is a local-first prototype. Profiles and requests are stored on the device
using `shared_preferences`; they are not synced between devices. Passwords are
salted and hashed locally, but this is not a substitute for secure production
authentication. A production service needs a backend, verified accounts,
access controls, and a secure database.
Blood group and donor eligibility must be confirmed by a qualified medical
professional. Pulse is not an emergency service.