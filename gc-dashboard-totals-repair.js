/* Final dashboard totals refresh repair: use the site's canonical company totals. */
(function(){
  function refresh(){
    try {
      if (typeof window.render === 'function') window.render();
      else if (typeof render === 'function') render();
    } catch (e) { console.error('Dashboard company totals refresh failed:', e); }
  }
  function wrapLoader(){
    if (typeof window.loadRecords !== 'function' || window.__gcTotalsLoadWrapped) return;
    window.__gcTotalsLoadWrapped = true;
    var previous = window.loadRecords;
    window.loadRecords = async function(){
      var result = await previous.apply(this, arguments);
      refresh();
      return result;
    };
  }
  document.addEventListener('DOMContentLoaded', function(){
    wrapLoader();
    refresh();
    document.addEventListener('visibilitychange', function(){ if (!document.hidden) refresh(); });
    window.addEventListener('gcCompanyMovementsUpdated', refresh);
    document.addEventListener('click', function(e){
      if (e.target.closest('[data-page], [data-nav], .nav button')) setTimeout(refresh, 80);
    });
  });
  // Existing code defines/re-wraps loadRecords in several later modules; reattach after those scripts.
  setTimeout(wrapLoader, 0);
  setTimeout(wrapLoader, 250);
  setTimeout(refresh, 500);
})();
