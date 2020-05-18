Script for AgileEngine backend test task

Call the script with two parameters, original html file and differ one.
Then it find in differ html element similar to id "make-everything-ok-button" in the original,
and output its xpath if found.

The script collects attributes of the original element, and for each element
in the differ html it calculates score as summary of matched attributes weights.
It checks tag, class, href, title, style, onclick and element text for exact match.

Set of checked attributes and their weights (scores) and target element id
hardcoded in the script as constants (this can be configured in the future if needed).

Tests:
```
$ ./find-similar-html.pl sample-0-origin.html sample-1-evil-gemini.html
/html/body/div[1]/div/div[3]/div[1]/div/div[2]/a[2]
$ ./find-similar-html.pl sample-0-origin.html sample-2-container-and-clone.html
/html/body/div[1]/div/div[3]/div[1]/div/div[2]/div/a
$ ./find-similar-html.pl sample-0-origin.html sample-3-the-escape.html
/html/body/div[1]/div/div[3]/div[1]/div/div[3]/a
$ ./find-similar-html.pl sample-0-origin.html sample-4-the-mash.html
/html/body/div[1]/div/div[3]/div[1]/div/div[3]/a
```
