Chiaro — Dev Journal
Entry 01 · September 27, 2026

Part 1 — Concept & Positioning
Started with the idea of a platform connecting models and photographers, differentiated from Model Mayhem, Model Management, One Model Place, and Kavyar.
Decisions made:
	• Niche: boudoir and fine art nude photography specifically, rather than general modeling. The narrower focus creates a natural filter — TFP-hunters don't belong in a space where both sides are already investing in the work.
	• Core differentiator: trust and professionalism are the product, not the directory. Vetting on both sides, structured shoot types (paid / defined collab), boundaries agreed before booking, no pay-to-publish.
	• Name: Chiaro (from chiaroscuro — the play of light and shadow).
	• Launch strategy: Denver founding cohort first, curated rather than open signup.
Open items: domain/handle/trademark availability unchecked; payment processor and app store policies around nudity-adjacent platforms still need verification.

Part 2 — Landing Page
Built and iterated on a marketing site, published as an artifact.
Progression:
	1. First pass — dark plum/teal gradient, model-first messaging, placeholder silhouette illustration
	2. Fixed silhouette overflow (contained to fixed-height box, clipped)
	3. Added color depth — warm amber glow, tinted section cards, colored step numbers
	4. Added a model application view (about you / your work / your goals / confirm) that swaps in without leaving the page
	5. Swapped placeholder art for real photography, four images total
	6. Full redesign into editorial magazine layout — masthead wordmark with kickers, "Issue No. 1" framing, scrolling ticker of platform rules, pull-quote manifesto, numbered folio sections, alternating half-page photo spreads
	7. Softened palette from red-orange/tan to cream and dusty rose
Note to self: the hero image still needs the Photoshop treatment (model larger than frame). Also need to confirm model releases cover web/marketing use.

Part 3 — Product Mechanics
Defined the feature that makes Chiaro structurally different: mandatory credits and feedback.
After each booked session, both parties must leave feedback and credit each other. Neither can book anything new until they do. This turns the reputation system from optional (where most platforms fail) into structural.
Flagged for later resolution:
	• Edge cases — cancellations, no-shows, ghosting. Need a path that doesn't trap someone in limbo.
	• Whether feedback is public, private-to-platform, or visible only to the other party. Public feedback pressures people toward politeness over honesty.
	• Timing — tied to the booking lifecycle, not a calendar trigger, so slow deliverables don't block the other party.

Part 4 — Technical Foundation
Stack decision: Ruby on Rails, with Hotwire Native for mobile later. One codebase instead of three, which matters building solo. Postgres from day one.
rails new chiaro --database=postgresql --css=tailwind
Gems: devise (auth), pundit (authorization), aasm (state machine), image_processing (uploads via Active Storage)

Part 5 — Data Model
User
	• Devise authentication
	• enum :role, { model: 0, photographer: 1, admin: 2 }, suffix: true
	• has_pending_feedback? — the method that gates new bookings
Booking
	• Two references to User (model_id, photographer_id), both needing foreign_key: { to_table: :users } since Rails would otherwise look for nonexistent models/authors tables
	• AASM state machine: requested → confirmed → completed → feedback_pending → credited, plus a disputed branch
	• credit event guarded by both_sides_gave_feedback?
Feedback
	• Belongs to booking and author (User)
	• Validates rating 1–5, comment minimum 10 characters
	• after_create callback attempts to advance the booking — the first person's feedback does nothing, the second person's triggers crediting automatically

Part 6 — Bugs & Lessons
A meaningful chunk of tonight was debugging. Worth recording:
Issue	Cause	Fix
relation "users" does not exist	add_column inside create_table block	Use t.integer / t.string inside the block
relation "models" does not exist	Rails guessed table name from reference name	foreign_key: { to_table: :users }
relation "authors" does not exist	Same cause, on Feedback	Same fix
wrong number of arguments on enum	Rails 7.1+ changed enum syntax	enum :role, {...} not enum role: {...}
Enum collides with ActiveRecord::Relation#model	:model generates a conflicting method	Add suffix: true
undefined method 'empty?' for Integer	AASM's enum: true needs a matching Rails enum declaration	Added enum :status, {...} to Booking
Sign-out route not matching	Devise sign-out is DELETE, not GET	button_to ... method: :delete
Sign-out button still failing	Nav block pasted inside <head>	Moved into <body>
Admin self-assignment possible	Strong params restrict keys, not values	before_validation :prevent_self_signup_as_admin, on: :create
Spec failing with response nil	post call missing from the test entirely	Added it back
Two process lessons from that table:
First — I chased a "flaky test" theory for several rounds on that last one when the real answer was a missing line of code. Isolating the test (rspec -e "...") proved it failed consistently, which should have redirected the investigation sooner. Reading the actual file beats theorizing about it.
Second — several bugs came from pasting snippets into files without checking what was already there. Worth reading the surrounding context before inserting.

Part 7 — Authorization
Pundit policies:
BookingPolicy — create? checks !user.has_pending_feedback?. show? restricts to the two parties. A Scope class filters index listings so nobody sees anyone else's bookings.
FeedbackPolicy — create? enforces three conditions at once: must be a party to the booking, booking must be in feedback_pending, and must not have already posted.
Security fix: admin role can no longer be self-assigned at signup. Removed from the dropdown, and hard-blocked at the model layer so a tampered request can't bypass it either. Promotion to admin is console-only now:
ruby
User.find_by(email: "...").update!(role: "admin")
Error handling: rescue_from Pundit::NotAuthorizedError redirects with a flash message instead of showing a raw 500.

Part 8 — Test Coverage
Spec	Covers
spec/models/booking_spec.rb	Booking credits only after both sides give feedback
spec/models/user_spec.rb	has_pending_feedback? flips correctly
spec/requests/bookings_spec.rb	5 examples — view permissions, auth redirect, booking creation, feedback gate
spec/requests/feedbacks_spec.rb	5 examples — party-only, timing, no duplicates, end-to-end crediting
All green. RSpec configured with Devise::Test::IntegrationHelpers for request specs.

Part 9 — Views
Built four views, all confirmed working in the browser end to end:
	• bookings/index — list scoped to your own bookings
	• bookings/new — form to request a photographer
	• bookings/show — details, AASM-aware action buttons (may_confirm? / may_complete?), feedback section
	• feedbacks/new — rating, comment, credit name
Also added a nav bar to the layout with sign-in/sign-out and current role display.
Verified manually: signed in as a model, requested a booking, confirmed it, marked complete, posted feedback. Whole chain works.
