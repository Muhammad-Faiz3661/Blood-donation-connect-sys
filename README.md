# Pulse blood donation connect

A Flutter app with separate donor and recipient portals. Recipients can find
available donor profiles by blood group and area, send requests, and track
responses. Donors can manage availability, accept or decline requests, and
mark donations complete.

## Run

Install the Flutter SDK, then from the project root run:

```sh
flutter pub get
flutter run
```

## App flows

- Create a donor or recipient profile with a blood group, phone number, and
	city or area.
- Search available donor profiles by blood group and location.
- Send a request with a hospital or clinic and optional note.
- Accepting a request reveals contact details to the two profiles involved.
- Donors can pause or resume appearing in searches; recipients can cancel
	pending requests.
- Switch or add profiles from the Profile tab to try both portals on one
	device.

## Data and safety

This is a local-first prototype. Profiles and requests are stored on the device
using `shared_preferences`; they are not synced between devices. Profile
switching is for testing and is not secure authentication. A production service
needs a backend, verified accounts, access controls, and a secure database.
Blood group and donor eligibility must be confirmed by a qualified medical
professional. Pulse is not an emergency service.