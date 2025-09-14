import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="username-check"
export default class extends Controller {
  static targets = ["feedback"]

  timeout = null

  check(event) {
    clearTimeout(this.timeout)
    const username = event.target.value

    if (username.length < 3) {
      this.feedbackTarget.innerHTML = "<span class='text-red-500'>Too short</span>"
      return
    }

    this.feedbackTarget.innerHTML = "<span class='text-gray-500'>Checking...</span>"

    this.timeout = setTimeout(() => {
        const currentId = this.element.dataset.currentId
        fetch(`/users/check_username?user_name=${encodeURIComponent(username)}&current_id=${currentId}`)
          .then(response => response.json())
          .then(data => {
            if (data.available) {
              this.feedbackTarget.innerHTML = "<span class='text-green-600'>Available ✓</span>"
            } else {
              this.feedbackTarget.innerHTML = "<span class='text-red-500'>Already taken ✗</span>"
            }
          })
    }, 400)
  }
}

