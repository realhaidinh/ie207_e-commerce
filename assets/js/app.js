// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import "flowbite/dist/flowbite.phoenix.js";
import { DataTable } from "simple-datatables";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.DataTable = {
  createDataTable(element) {
    new DataTable(element, {
      searchable: element.dataset.searchable === "true",
      sortable: element.dataset.sortable === "true"
    })
    const tbody = element.querySelector('tbody')
    tbody.setAttribute("id", element.dataset.tbodyId)
    element.dataset.tbodyPhxUpdate && tbody.setAttribute("phx-update", element.dataset.tbodyPhxUpdate)
  },
  mounted() {
    this.createDataTable(this.el)
  },
  updated() {
    this.createDataTable(this.el)
  }
}
Hooks.CurrencyFormat = {
  formatCurrency(value) {
    return new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(value)

  },
  mounted() {
    this.el.innerText = this.formatCurrency(this.el.innerText);
  },
  updated() {
    this.el.innerText = this.formatCurrency(this.el.innerText);
  }
}
Hooks.ImageGallery = {
  mounted() {
    const modalImage = document.getElementById("image-modal")
    const updateModalImage = (newImage) => {
      modalImage.src = newImage.src
    }
    const galleryItems = this.el.querySelectorAll(".gallery-item")
    galleryItems.forEach((item) => {
      item.addEventListener("click", () => {
        updateModalImage(item)
      })
    })
  }
}
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

