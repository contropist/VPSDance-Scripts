// (function(){
// https://purge.jsdelivr.net/gh/VPSDance/scripts@main/files/ipt.js
window.tr = () => {
  const from = $('#note :selected').text();
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
  console.warn(html);
  copy(html);
}
tr();
// }());
