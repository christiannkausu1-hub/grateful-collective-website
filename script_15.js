
(function(){
  function makeShopCardCollapsible(panel,label){
    if(!panel||panel.dataset.shopCollapseReady==='1')return;
    const heading=panel.querySelector(':scope > h3');if(!heading)return;
    const body=document.createElement('div');body.className='school-collapsible-body';
    let node=heading.nextSibling;while(node){const next=node.nextSibling;body.appendChild(node);node=next;}
    const head=document.createElement('div');head.className='school-collapsible-heading';
    heading.remove();head.appendChild(heading);
    const toggle=document.createElement('button');toggle.type='button';toggle.className='school-card-toggle';toggle.textContent='+';toggle.setAttribute('aria-expanded','false');toggle.setAttribute('aria-label','Open '+label);
    head.appendChild(toggle);panel.insertBefore(head,panel.firstChild);panel.appendChild(body);body.hidden=true;
    toggle.addEventListener('click',()=>{const opening=body.hidden;body.hidden=!opening;toggle.textContent=opening?'−':'+';toggle.setAttribute('aria-expanded',String(opening));toggle.setAttribute('aria-label',(opening?'Close ':'Open ')+label);});
    panel.dataset.shopCollapseReady='1';
  }
  function init(){
    const root=document.getElementById('page-shops');if(!root)return;
    const panels=[...root.querySelectorAll(':scope > .panel')];
    const start=panels.findIndex(panel=>/record a sale/i.test(panel.querySelector(':scope > h3')?.textContent||''));
    if(start<0)return;
    panels.slice(start).forEach(panel=>makeShopCardCollapsible(panel,(panel.querySelector(':scope > h3')?.textContent||'Shop details').trim().toUpperCase()));
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})();
