import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewModal", "editModal", "viewName", "viewDescription", "viewInfo", "viewEditBtn", "form", "editName", "editDescription", "editInfo"]

  openView(event) {
    const { name, description, information, editUrl } = event.currentTarget.dataset
    
    this.viewNameTarget.textContent = name
    this.viewDescriptionTarget.textContent = description
    this.viewInfoTarget.textContent = information || "Blank"
    this.viewEditBtnTarget.dataset.url = editUrl
    this.viewEditBtnTarget.dataset.name = name
    this.viewEditBtnTarget.dataset.description = description
    this.viewEditBtnTarget.dataset.information = information

    this.viewModalTarget.classList.remove("hidden")
  }

  openEditFromView() {
    this.closeView()
    this.openEdit(this.viewEditBtnTarget)
  }

  openEdit(element) {
    // element can be the button itself or passed from openEditFromView
    const target = element.currentTarget || element
    const { url, name, description, information } = target.dataset

    this.formTarget.action = url
    this.editNameTarget.value = name
    this.editDescriptionTarget.value = description
    this.editInfoTarget.value = information || ""

    this.editModalTarget.classList.remove("hidden")
  }

  closeView() {
    this.viewModalTarget.classList.add("hidden")
  }

  closeEdit() {
    this.editModalTarget.classList.add("hidden")
  }
}
