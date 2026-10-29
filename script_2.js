
(function(){
 const groups={
  dashboard:[['Pupils','pupils'],['Lunch payments','lunch'],['Tests & fees','tests'],['School expenses','school-expenses'],['Reports','reports']],
  pupils:[['Lunch payments','lunch'],['Tests & fees','tests'],['School expenses','school-expenses']],
  lunch:[['Pupils','pupils'],['Tests & fees','tests'],['School expenses','school-expenses']],
  tests:[['Pupils','pupils'],['Lunch payments','lunch'],['School expenses','school-expenses']],
  'school-expenses':[['Pupils','pupils'],['Workers & payroll','payroll'],['Expenses','transactions'],['Reports','reports']],
  payroll:[['School expenses','school-expenses'],['Expenses','transactions'],['Reports','reports']],
  transactions:[['School expenses','school-expenses'],['Shops','shops'],['Rentals','rentals'],['Trade payables','payables'],['Reports','reports']],
  rentals:[['Expenses','transactions'],['Trade payables','payables'],['Reports','reports']],
  shops:[['Expenses','transactions'],['Trade payables','payables'],['Reports','reports']],
  payables:[['Expenses','transactions'],['Shops','shops'],['Reports','reports']],
  reports:[['Dashboard','dashboard'],['School expenses','school-expenses'],['Expenses','transactions'],['Rentals','rentals'],['Shops','shops']]
 };
 function currentPage(){const el=document.querySelector('.page:not(.hidden)');return el?el.id.replace(/^page-/,''):''}
 function draw(){const id=currentPage(),page=document.getElementById('page-'+id);if(!page)return;let panel=page.querySelector(':scope > .gc-related-panel');const items=(groups[id]||[]).filter(x=>typeof allowedPages!=='function'||allowedPages().has(x[1]));if(!items.length){panel?.remove();return}if(!panel){panel=document.createElement('div');panel.className='gc-related-panel';panel.innerHTML='<h3>GO TO RELATED SECTION</h3><div class="gc-related-links"></div>';const head=page.querySelector(':scope > .head');if(head)head.insertAdjacentElement('afterend',panel);else page.insertAdjacentElement('afterbegin',panel)}const links=panel.querySelector('.gc-related-links');links.replaceChildren();items.forEach(([label,target])=>{const b=document.createElement('button');b.type='button';b.textContent=label;b.addEventListener('click',()=>{if(typeof window.page==='function')window.page(target);else document.querySelector('[data-page="'+target+'"]')?.click()});links.appendChild(b)});}
 const old=window.page;if(typeof old==='function'&&!old.__gcRelatedPanelWrapped){const wrapped=async function(...args){const result=await old.apply(this,args);draw();return result};wrapped.__gcRelatedPanelWrapped=true;window.page=wrapped}
 document.addEventListener('DOMContentLoaded',draw);setTimeout(draw,0);
})();
