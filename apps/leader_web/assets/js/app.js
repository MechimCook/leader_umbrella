
import css from "../css/app.css"

import 'bootstrap';


window.onload = () => {
  Array.from(document.querySelectorAll(".add-form-field"))
  .forEach(el => {
    el.onclick = ({target: {dataset}}) => {
      let container = document.getElementById(dataset.container);
      let index = container.dataset.index;
      let newRow = dataset.prototype;
      container.insertAdjacentHTML("beforeend",       newRow.replace(/__name__/g, index));
      container.dataset.index = parseInt(container.dataset.index) + 1;
    }
  });
}

import "phoenix_html"
