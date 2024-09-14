# Subdomain Handler Demo

This is just a demo server for the [SubdomainHandler](https://github.com/bhaze31/subdomain-handler/) package to segment controllers based on the subdomain. The package contains more info on how it works, while this README explains how to set up the demo server.

This server and its views will never win a design award, it might not be how you set up the code, and thats fine. It is just to demo how subdomains work. That is all.

## The video tutorial

If you hate reading, just watch the video of how it works [here](https://www.youtube.com). If you want to run it yourself, look below.

## Pre-requisites

To run this locally, I use nginx and dnsmasq to resolve the domain to my local server. While how this works and setting this up is outside the scope of the demo server, there is an included nginx.conf configuration that can be used. As this is built on a 2021 Macbook Pro (Sonoma 16.4 on an M1 chip) with Homebrew installed, I will give brief instructions with absolutely zero troubleshooting help below for my OS:

First, need to install dnsmasq and nginx:

```
brew install dnsmasq nginx
```

Then we need to send all requests to `.local` through dnsmasq. You could use another domain if you are so inclined, but this is what I am using:

```
echo 'address=/.local/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
```

Next setup a resolver to point local host to dnsmasq at `local`. If you used a different domain above, change the `/local` to be the resolved you want:

```
sudo mkdir -p /etc/resolver
sudo tee /etc/resolver/local > /dev/null <<EOF
nameserver 127.0.0.1
EOF
```

Restart dnsmasq so it picks up that config file:

```
sudo brew services restart dnsmasq
```

Now check in the terminal that this works:

```
dig testing.anydomain.local @127.0.0.1
```

And you should see an `Answer` section respond. We also wanna make sure that we didn't break anything, so go ahead and run a ping to make sure we get a response:

```
ping -c 1 www.google.com

ping -c 1 anothertest.randomdomain.local
```

Now that we have dnsmasq pointing to us, add a `yourdomain.conf` file at /opt/homebrew/etc/nginx/servers, which should be where homebrew sets up the directory. If thats not there, then make sure the install worked or use Google or DuckDuckGo or whatever your search engine is to ask "Where is nginx configuration located". Remember, this is Mac specific.

You can copy the file directly in this repo, or make the file and add the following content:

```
server {
  listen 80;
  listen [::]:80;
  
  server_name yourdomain.local *.wanderlust.local;
  
  location / {
    proxy_pass http://127.0.0.1:3500;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Remember, if you changed the domain from `local` before to change it here too in the server_name. Also, make sure that you are using the correct port that points to your server in the `proxy_pass` line. Refer to your search engine for `nginx reverse_proxy` if you cannot set it up.

I'm not the person who created [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) or [homebrew](https://brew.sh) or [nginx](https://nginx.org) or any of the absolutely INCREDIBLE OS software that is used to enable this. If you have questions, seek out their documentation and support them if you are able to. That goes for the awesome people at [Vapor](https://vapor.codes) as well.

## Running the server

**If you are on the starter branch, none of the domains will be active. Make sure that you are on the branch trunk.**
**If you have not done the prerequisites, this will not work. Please read the whole README. I know you wanna skim to just the code blocks, but please go back**

Start the server as you normally would for a Vapor server, and you will have the following routes:

- admin.yourdomain.local: Where you can create new projects
- app.yourdomain.local: Where you can give updates for the projects
- \*.yourdomain.local: Where people can view the updates for a project
- www.yourdomain.local: Just a hello message to you folks
- yourdomain.local: The same hello message

The way this works is by following these code paths:

First we register routers in the `routes.swift` app using the following code:

```
try app.register(collection: AdminController(), at: "admin")
  
try app.register(collection: AppController(), at: "app")
  
try app.register(collection: PublicPagesController(), at: "*")
```

The controllers are regular Vapor `RouteCollections` which have a couple handlers. However, we register them at specific subdomains which means they will only respond when the domain matches. The last route is a `wildcard` route, meaning it will match anything. If that is confusing, refer to the package above for how the handler works.

In `configure.swift` we call `try routes(app)` which is where the previous code is run. After we configure all the routes and subdomains, we add the SubdomainHandler middleware like so:

```
app.enableSubdomains()
``` 

This will both register the middleware used to handle the subdomain responders and to build TrieRouters at each subdomain that you have registered routes for. Since this is the _only_ time that we register routes, it ***must*** be called at the end of the configuration file.

And thats it! Now you can have multiple routes that have the same path but at different subdomains.
