import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "items"]

  add(event) {
    event.preventDefault()

    const id = new Date().getTime()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", id)
    this.itemsTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()

    const item = event.target.closest("[data-nested-form-target='item']")
    const destroyInput = item.querySelector("input[name*='[_destroy]']")

    if (destroyInput) {
      destroyInput.value = "1"
      item.classList.add("d-none")
    } else {
      item.remove()
    }
  }
}
