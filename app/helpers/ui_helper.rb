# Small view helpers shared across the Chiaro views.
module UiHelper
  STATUS_LABELS = {
    "requested"        => "Requested",
    "confirmed"        => "Confirmed",
    "completed"        => "Completed",
    "feedback_pending" => "Feedback due",
    "credited"         => "Credited",
    "disputed"         => "Disputed",
    "cancelled"        => "Cancelled"
  }.freeze

  CANCEL_REASON_LABELS = {
    "changed_plans" => "Plans changed",
    "no_response"   => "No response",
    "no_show"       => "No-show",
    "other"         => "Other"
  }.freeze

  # The four beats from the landing page: Request → Agree → Shoot → Credit.
  BOOKING_STEPS = %w[Requested Confirmed Shot Credited].freeze

  def status_label(booking)
    STATUS_LABELS.fetch(booking.status.to_s, booking.status.to_s.humanize)
  end

  def status_badge(booking)
    tone =
      case booking.status.to_s
      when "credited"                       then "border-brass text-brass"
      when "feedback_pending", "completed"  then "border-brass bg-brass text-ink"
      when "cancelled", "disputed"          then "border-line-strong text-stone-dim"
      else                                       "border-line-muted text-ivory"
      end
    tag.span status_label(booking).upcase,
             class: "inline-flex items-center border px-2.5 py-1 text-[11px] font-semibold tracking-[0.16em] #{tone}"
  end

  # 0..3 for the step tracker, nil when the booking left the happy path.
  def booking_step_index(booking)
    case booking.status.to_s
    when "requested"                     then 0
    when "confirmed"                     then 1
    when "completed", "feedback_pending" then 2
    when "credited"                      then 3
    end
  end

  def cancel_reason_label(reason)
    CANCEL_REASON_LABELS.fetch(reason.to_s, reason.to_s.humanize)
  end

  def shoot_type_label(type)
    type.to_s.humanize # "fine_art_nude" → "Fine art nude"
  end

  def role_label(user)
    user.role.to_s.humanize
  end

  # The other person on a booking, from `user`'s point of view.
  def other_party(booking, user)
    booking.model_id == user.id ? booking.photographer : booking.model
  end

  # Round avatar, or initials when no photo has been uploaded.
  def avatar_for(user, size: 40)
    profile = user.profile
    style = "width: #{size}px; height: #{size}px"
    if profile&.avatar&.attached?
      image_tag profile.avatar, alt: "", style: style,
                class: "shrink-0 rounded-full border border-line-strong object-cover"
    else
      initials = user.display_name.to_s.split.map(&:first).first(2).join.upcase
      tag.span initials, style: style, "aria-hidden": true,
               class: "inline-flex shrink-0 items-center justify-center rounded-full bg-line " \
                      "font-display text-sm text-stone"
    end
  end

  def instagram_url(handle)
    "https://instagram.com/#{handle.to_s.delete_prefix('@').strip}"
  end

  # Numbered section heading in the editorial style: "ii.  Portfolio"
  def folio_heading(numeral, title, tag_name: :h2, size: "text-[40px]")
    tag.div class: "flex items-baseline gap-4" do
      tag.span("#{numeral}.", class: "folio") +
        content_tag(tag_name, title, class: "m-0 font-display font-normal #{size}")
    end
  end
end
