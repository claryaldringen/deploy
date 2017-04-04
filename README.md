# deploy
Deploy Tool for CMS.

Usage: ./deploy.sh \<PARAMETER>
Deploy of CMS projects.

Possible parameters:
 *	--project, -p   Sets project to deploy.
 * --help, -h		    Shows this help.

Possible values of --project parameter:

 * cms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Deploys CMS - shared part of all webs.
 * writer, backend&nbsp;&nbsp;&nbsp;Deploys CmsWriter - shared backend of all webs.
 * \<part of name>&nbsp;&nbsp;&nbsp;Deploys webs with \<part of name> in their names.
 * all&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Deploys all frontend webs.

Example: 
```bash 
./deploy.sh -p .cz
```
This will deploy all *.cz webs.
