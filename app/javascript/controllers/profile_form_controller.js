import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "function",
    "employmentTypes",
    "salary",
    "percentage",
    "revenue",
    "bigStatus",
    "bigNumber",
    "skillGroup"
  ]

  connect() {
    this.refresh()
  }

  refresh() {
    const jobFunction = this.functionTarget.value
    const employmentTypes = this.checkedEmploymentTypes()
    const clinical = ["General dentist", "Dental hygienist", "Prevention assistant", "Paro-prevention assistant", "Specialist"].includes(jobFunction)

    this.toggle(this.salaryTarget, employmentTypes.includes("Employed"))
    this.toggle(this.percentageTarget, ["Self-employed", "Freelance", "Percentage-based"].some((type) => employmentTypes.includes(type)))
    this.toggle(this.revenueTarget, clinical)
    this.toggle(this.bigStatusTarget, clinical)
    this.toggle(this.bigNumberTarget, clinical)

    this.skillGroupTargets.forEach((group) => {
      this.toggle(group, group.dataset.group === this.skillGroupFor(jobFunction))
    })
  }

  checkedEmploymentTypes() {
    return Array.from(this.employmentTypesTarget.querySelectorAll("input:checked")).map((input) => input.value)
  }

  skillGroupFor(jobFunction) {
    if (["General dentist", "Specialist"].includes(jobFunction)) return "Dentist"
    if (["Dental hygienist", "Prevention assistant", "Paro-prevention assistant"].includes(jobFunction)) return "Dental hygienist"
    if (["Dental assistant", "Orthodontic assistant"].includes(jobFunction)) return "Dental assistant"
    if (jobFunction === "Front-office / receptionist") return "Front-office"
    if (jobFunction === "Practice manager") return "Practice manager"
    if (jobFunction === "Dental technician") return "Dental technician"

    return ""
  }

  toggle(element, visible) {
    element.classList.toggle("d-none", !visible)
  }
}
