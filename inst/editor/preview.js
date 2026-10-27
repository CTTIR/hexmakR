(function () {
  function setup() {
    var host = document.getElementById('preview-stage');
    if (!host || host.dataset.pointerReady) return;
    host.dataset.pointerReady = 'true';
    var drag = null;
    function image() { return host.querySelector('#preview img'); }
    function align() {
      var img = image();
      var overlay = document.getElementById('selection_overlay');
      if (!img || !overlay || !img.naturalWidth) return;
      var box = img.getBoundingClientRect();
      var parent = host.getBoundingClientRect();
      overlay.style.left = (box.left - parent.left) + 'px';
      overlay.style.top = (box.top - parent.top) + 'px';
      overlay.style.width = box.width + 'px';
      overlay.style.height = box.height + 'px';
    }
    function point(event, img, clamp) {
      var box = img.getBoundingClientRect();
      if (!box.width || !box.height) return null;
      var x = (event.clientX - box.left) / box.width;
      var y = 1 - (event.clientY - box.top) / box.height;
      if (!clamp && (x < 0 || x > 1 || y < 0 || y > 1)) return null;
      return {x: Math.max(0, Math.min(1, x)), y: Math.max(0, Math.min(1, y)), normalized: true};
    }
    host.addEventListener('load', align, true);
    host.addEventListener('dragstart', function (event) { event.preventDefault(); });
    host.addEventListener('pointerdown', function (event) {
      var img = image();
      if (event.button !== 0 || event.target !== img) return;
      var start = point(event, img, false);
      if (!start) return;
      drag = {start: start, clientX: event.clientX, clientY: event.clientY,
        render: img.getAttribute('data-render-id'), pointer: event.pointerId};
      if (img.setPointerCapture) img.setPointerCapture(event.pointerId);
    });
    host.addEventListener('pointermove', function (event) {
      if (!drag || drag.pointer !== event.pointerId) return;
      if (Math.hypot(event.clientX - drag.clientX, event.clientY - drag.clientY) >= 3) {
        host.classList.add('preview-dragging');
        event.preventDefault();
      }
    });
    function finish(event, cancel) {
      if (!drag || drag.pointer !== event.pointerId) return;
      var old = drag;
      drag = null;
      host.classList.remove('preview-dragging');
      var img = image();
      if (cancel || !img || old.render !== img.getAttribute('data-render-id')) return;
      if (Math.hypot(event.clientX - old.clientX, event.clientY - old.clientY) < 3) return;
      var end = point(event, img, true);
      if (end && window.Shiny) Shiny.setInputValue('preview_drag',
        {start: old.start, end: end, render_id: old.render}, {priority: 'event'});
    }
    host.addEventListener('pointerup', function (event) { finish(event, false); });
    host.addEventListener('pointercancel', function (event) { finish(event, true); });
    if (window.ResizeObserver) new ResizeObserver(align).observe(host);
    new MutationObserver(align).observe(host, {childList: true, subtree: true});
    window.addEventListener('resize', align);
    align();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', setup);
  else setup();
})();
