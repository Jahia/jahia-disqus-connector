 Jahia Disqus connector
=======================

## Overview
The Jahia Disqus connector module provide an integration between your Digital Factory sites and your Disqus Account. After setting up your DIsqus information.
You will be able to put Disqus Threads in your pages and templates using jnt:disqusThread component.

## Goals

- Provide an integration with Disqus.
- Experience Disqus javascript API calls
- Provide a Disqus Thread component


## Version

Jahia Disqus connector v1.0.0

---

## TODO
- Fix Jahia API calls Exception in Digital Factory console.
- Wait for data to be replicated in live after saving the Disqus account information form.

---

## Presentation
### Disqus Account information form
This form allows you to save the needed information about your Disqus account.
In this form you will have to enter your Disqus shortname and public key.
Disqus public key can be found on your disqus apps page (https://disqus.com/api/applications/).

If those information are correct, in the table down the form should appear the list of your Disqus threads.


### Disqus Thread component
This component reads the Disqus settings in JCR and create a Disqus Thread using the title of its bounded component and the page URL.
It can be put in pages areas or templates (like event display templates for example).
