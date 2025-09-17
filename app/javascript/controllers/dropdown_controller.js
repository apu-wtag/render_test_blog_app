import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    // Close any other open dropdowns first
    this.hideAll()

    // Decide dropdown direction dynamically
    this.setDirection()

    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event?.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  hideAll() {
    document.querySelectorAll("[data-dropdown-target='menu']").forEach(menu => {
      if (menu !== this.menuTarget) menu.classList.add("hidden")
    })
  }

  setDirection() {
    const rect = this.element.getBoundingClientRect()
    const dropdownHeight = this.menuTarget.offsetHeight || 160 // fallback height
    const spaceBelow = window.innerHeight - rect.bottom
    const spaceAbove = rect.top

    if (spaceBelow < dropdownHeight && spaceAbove > dropdownHeight) {
      // Open upward
      this.menuTarget.classList.remove("mt-2")
      this.menuTarget.classList.add("bottom-full", "mb-2")
    } else {
      // Open downward
      this.menuTarget.classList.remove("bottom-full", "mb-2")
      this.menuTarget.classList.add("mt-2")
    }
  }
}
