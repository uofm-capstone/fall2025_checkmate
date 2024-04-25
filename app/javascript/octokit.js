import { Octokit } from "https://esm.sh/octokit";

console.log("Javascript File is executed.");

document.getElementById('github-form').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent the form from submitting the traditional way

    const repoOwner = document.getElementById('repo-owner').value;
    const repoName = document.getElementById('repo-name').value;
    const accessToken = document.getElementById('access-token').value;
    const startDate = document.getElementById('start-date').value;
    const endDate = document.getElementById('end-date').value;

    const octokit = new Octokit({
        auth: accessToken,
    });
    
    // Get a reference to the commit-table and its tbody
    const commitTable = document.getElementById('commit-table');
    const commitTableBody = commitTable.querySelector('tbody');


    // Get a reference to the commit-list element
    const commitList = document.getElementById('commit-list');

    octokit.rest.repos.listCommits({
        owner: repoOwner,
        repo: repoName,
        since: startDate,
        until: endDate,
    })

        .then((response) => {
            const commits = response.data;

            const authorCommits = {};
            const commitDates = {};

            // Process commits to group by author and date
            commits.forEach((commit) => {
                const author = commit.commit.author.name;
                const date = commit.commit.author.date.slice(0, 10); // Extract just the YYYY-MM-DD part

                if (!authorCommits[author]) {
                    authorCommits[author] = {};
                }
                if (!authorCommits[author][date]) {
                    authorCommits[author][date] = 0;
                }
                authorCommits[author][date]++;
                commitDates[date] = true;
            });

            // Generate a list of all dates for the x-axis
            const allDates = Object.keys(commitDates).sort();

            // Generate datasets for each author
            const datasets = Object.keys(authorCommits).map(author => {
                const data = allDates.map(date => authorCommits[author][date] || 0);

                return {
                    label: author,
                    data: data,
                    fill: false,
                    borderColor: getRandomColor(), // Function to generate random color
                    tension: 0.1
                };
            });

            // Create the chart with these datasets
            createCommitChart(allDates, datasets);
        })

    .catch((error) => {
        console.log("Request failed.")
        
        // Handles errors
        console.error(error);
    });
});

function getRandomColor() {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

function createCommitChart(labels, datasets) {
    const ctx = document.getElementById('myChart').getContext('2d');

    // Destroys previous chart instance (if it exists)
    if (window.myChartInstance) {
        window.myChartInstance.destroy();
    }

    window.myChartInstance = new Chart(ctx, {
        type: 'line', // Change type here like 'bar', 'line', etc.
        data: {
            labels: labels,
            datasets: datasets
        },
        options: {
            scales: {
                x: {
                    title: {
                        display: true,
                        text: 'Date'
                    }
                },
                y: {
                    title: {
                        display: true,
                        text: 'Number of Commits'
                    },
                    beginAtZero: true
                }
            }
        }
    });
}



document.addEventListener('DOMContentLoaded', (event) => {
    createDummyChart(); // Call the function to create the dummy chart
});
