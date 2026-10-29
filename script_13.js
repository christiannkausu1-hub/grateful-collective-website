
(function(){
  function makeCollapsible(panel, heading, label){
    if(!panel||panel.dataset.collapsibleReady==='1')return;
    const body=document.createElement('div');body.className='school-collapsible-body';
    const nodes=[...panel.childNodes];let passedHeading=false;
    for(const node of nodes){
      if(node===heading){passedHeading=true;continue;}
      if(passedHeading)body.appendChild(node);
    }
    const head=document.createElement('div');head.className='school-collapsible-heading';
    if(heading.parentNode)heading.parentNode.removeChild(heading);
    head.appendChild(heading);
    const toggle=document.createElement('button');toggle.type='button';toggle.className='school-card-toggle';toggle.textContent='+';toggle.setAttribute('aria-label','Open '+label);toggle.setAttribute('aria-expanded','false');
    head.appendChild(toggle);panel.insertBefore(head,panel.firstChild);panel.appendChild(body);body.hidden=true;
    toggle.addEventListener('click',()=>{const opening=body.hidden;body.hidden=!opening;toggle.textContent=opening?'−':'+';toggle.setAttribute('aria-expanded',String(opening));toggle.setAttribute('aria-label',(opening?'Close ':'Open ')+label)});
    panel.dataset.collapsibleReady='1';
  }
  const feeForm=document.getElementById('gradeFeeForm');if(feeForm){const panel=feeForm.closest('.panel');makeCollapsible(panel,panel?.querySelector('h3'),'FEES BY GRADE')}
  const attendance=document.querySelector('#page-pupils .gc-school-tools');if(attendance)makeCollapsible(attendance,attendance.querySelector('h3'),'ATTENDANCE REGISTER');
  const register=document.querySelector('#page-pupils .pupil-register-panel');if(register){const heading=register.querySelector('.pupil-register-heading');if(heading)makeCollapsible(register,heading,'PUPIL REGISTER')}
  const transfers=document.querySelector('#page-pupils .transfer-panel');if(transfers)makeCollapsible(transfers,transfers.querySelector('h3'),'TRANSFERS');
})();


