// (function(){
// https://purge.jsdelivr.net/gh/VPSDance/scripts@main/files/ipt.js

// cp(text)
window.__cp = (text) => {
  const dummy = document.createElement('textarea');
  document.body.appendChild(dummy);
  dummy.value = text;
  dummy.select();
  document.execCommand('copy');
  document.body.removeChild(dummy);
}

window.__tr = () => {
  // const name = $('#note :selected').text();
  const ip = $('#ip').val();
  const ipMask = ip.split('.').slice(0, 2).concat('*', '*').join('.');
  const ipReg = new RegExp(`\\b${ip.split('.').join('\\.')}\\b`, 'g');
  let html = `traceroute to ${ip}, 30 hops max, 32 byte packets\n`;

  $('#trace tbody tr').map((_, line) => {
    let [ttl, ip, host, location, as, time] = $(line).find('td').toArray().map(o => o.innerText.split('\n'));
    const valIndex = ip.findIndex(o => !!o && o !== '*');
    const val = (arr) => arr[valIndex] || arr[0];
    [ttl, host, ip, time, as, location] = [val(ttl), val(host), val(ip), val(time), val(as), val(location)];
    ip = (ip === host ? '' : ` (${ip})`);
    time = time.split(' / ')[1] || time;
    const item = host === '*' ? `${ttl}  *` : `${ttl}  ${host}${ip}  ${time} ms  ${as}  ${location}`;
    html+= `${item}\n`;
  });
  html = html.replace(ipReg, ipMask);
  // console.warn(html);
  // __cp(html);
  return html;
}
// tr();

__IDS__ = [
  {id: '502', name: '广东电信'},
  {id: '764', name: '江苏电信'},
  // {id: '896', name: 'Shanghai CT'},
  {id: '11', name: 'Chongqing CT'},

  {id: '503', name: '广东联通'},
  {id: '765', name: '江苏联通'},
  // {id: '1078', name: '上海联通'},
  // {id: '1240', name: '上海联通9929'},
  {id: '12', name: '重庆联通'},
  // {id: '662', name: '湖南联通'},

  {id: '424', name: '广东移动'},
  {id: '766', name: '江苏移动'},
  {id: '924', name: '重庆移动'},
  // {id: '946', name: '重庆移动'},
];

window.__process = (item) => new Promise((resolve, reject) => {
  const cb = (text) => {
    clearInterval(item._t);
    resolve({ ...item, text });
  }
  $('select[name="id"]').val(item.id);
  // return setTimeout(() => cb('test ' + item.name), 2 * 1000);
  $('#btn').trigger('click');
  const l = $('#load');
  setTimeout(() => cb(''), 60 * 1000); // timeout
  item._t = setInterval(() => {
    const done = l.is(':hidden');
    if (!done) return;
    cb($('#trace tbody tr').length > 1 ? __tr() : '');
  }, 1000);
});
window.__queue = (items) => {
  if (!$('#ip').val()) return Promise.reject('no ip');
  let arr = [];
  const run = async () => {
    for(let o of items) {
      let v = await __process(o);
      arr.push(v);
    }
    return arr;
  }
  return run();
};
// __IDS__ = [ {id: '503', name: '广东联通'}, {id: '424', name: '广东移动'}, ];
window.__fetch = () => __queue(__IDS__).then(arr => {
  // console.warn(arr);
  const r = arr.filter(o => !!o.text)
    .map(({ name, text }) => `${name}\n${text}`).join(`\n${new Array(70).join('-')}\n`);
  console.warn(r);
  window.__d__ = r;
  __cp(window.__d__);
});
window.__init = () => {
  const form = $('#ps');
  form.next('button').remove();
  form.after('<button onclick="__fetch()">test</button>');
  $('select[name="t"]').val('T');
  // $('select[name="id"]').val();
}
__init();


// }());
