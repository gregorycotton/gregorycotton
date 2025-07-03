// Really quick script to test rate limit on gregorycotton.ca
console.log("Start rate limit test");

const requestUrl = 'server.php?action=get_projects';
const totalRequests = 70;

for (let i = 1; i <= totalRequests; i++) {
  fetch(requestUrl)
    .then(response => {
      console.log(`Request #${i}: Status = ${response.status}`);
      if (!response.ok && response.status !== 429) {
         console.error(`Request #${i} failed with an unexpected error.`);
      }
    })
    .catch(error => {
      console.error(`Request #${i} completely failed:`, error);
    });
}