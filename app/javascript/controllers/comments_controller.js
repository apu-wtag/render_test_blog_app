import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comments"
export default class extends Controller {
  static targets = [ "replyForm", "replies" ]

  // Reply form toggle
  toggle() {
    this.replyFormTarget.classList.toggle("hidden")
  }

  hide() {
    this.replyFormTarget.classList.add("hidden")
  }

  // Replies toggle
  toggleReplies(event) {
    event.preventDefault()

    if (this.hasRepliesTarget) {
      this.repliesTarget.classList.toggle("hidden")

      // Change button text dynamically
      const btn = event.currentTarget
      if (this.repliesTarget.classList.contains("hidden")) {
        btn.textContent = btn.textContent.replace("Hide", "View")
      } else {
        btn.textContent = btn.textContent.replace("View", "Hide")
      }
    }
  }
}
