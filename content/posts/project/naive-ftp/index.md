---
title: "Naive-FTP: 一个简易的 FTP 服务端 & 客户端"
date: 2021-01-11T03:08:00+08:00

tags: [计网, FTP, Socket 编程, Python, Vue, TypeScript]
categories: [project]
featuredImage: https://hakula-1257872502.file.myqcloud.com/images/article-covers/86286793.webp
license: CC BY-NC-SA 4.0

hiddenFromHomePage: false
hiddenFromSearch: false
---

Naive-FTP is a simple FTP server & client, written in Python and TypeScript.

Computer Networks @ Fudan University, fall 2020.

<!--more-->

{{< admonition info 封面出处 >}}
[カラスの集め物 - @MISSILE228](https://www.pixiv.net/artworks/86286793)
{{< /admonition >}}

{{< admonition success 源码地址 >}}
[:(fab fa-github):  hakula139 / Naive-FTP](https://github.com/hakula139/Naive-FTP)
{{< /admonition >}}

{{< image src="assets/gui.webp" caption="Naive-FTP" >}}

## Overview

- Implements a subset of the File Transfer Protocol (FTP) from scratch with raw socket programming in Python, using built-in modules only.
- Provides a graphical user interface (GUI) to the client side, built with [Vue 3][vue3] and designed based on [Ant Design of Vue][antdv2].
- Builds an API server with [Flask][flask] to handle communications between the client GUI and the server.

[vue3]: https://v3.vuejs.org
[antdv2]: https://2x.antdv.com
[flask]: https://flask.palletsprojects.com

## Getting Started

### 0 Prerequisites

To set up the environment, you need to have the following dependencies installed.

- [Python][python] 3.7 or later
- [Node.js][nodejs] 13 or later
- [yarn]

[python]: https://www.python.org/downloads
[nodejs]: https://nodejs.org/en/download
[yarn]: https://classic.yarnpkg.com/en/docs/install

### 1 Installation

First, obtain the Naive-FTP package.

```bash
git clone https://github.com/hakula139/Naive-FTP.git
cd Naive-FTP
```

Before installing, it's recommended to set up a virtual environment, so that any changes will not affect your global configuration.

```bash
python -m venv venv
./venv/Scripts/activate
```

Now you can build the project using `setup.py`.

```bash
python setup.py install
```

Make sure you have the latest version of `setuptools` installed.

```bash
python -m pip install --upgrade setuptools
```

#### 1.1 GUI support

A graphical user interface (GUI) is optional for Naive-FTP, so if you prefer to use a command-line interface (CLI), you can safely skip this step.

Here we use [yarn] to build the client GUI. It may take some time, so perhaps there's time for you to make yourself a cup of coffee... if you like.

```bash
cd app && yarn && yarn build && cd ..
```

Besides, the following dependencies are required for the API server, which exposes the essential APIs for the client GUI to communicate with the server. Install these packages using [pip].

```bash
pip install flask waitress
```

[pip]: https://pypi.org/project/pip

### 2 Usage

#### 2.1 Server

After a successful installation, you can start the Naive-FTP server using the command below. The server will listen to port `2121` by default.

```bash
python ./naive_ftp/server/server.py
```

You should see the following welcome message. Press `q` to exit.

```text
Welcome to Naive-FTP server! Press q to exit.
```

#### 2.2 Client CLI

If you just want to use a CLI, use this command to start it. The client will attempt to establish a connection to `localhost:2121` by default.

```bash
python ./naive_ftp/client/client.py
```

To get started, try the command `help` to show all available commands. All commands are case-insensitive.

```text
> help
```

Currently, we support the commands as follows.

```text
HELP                         Show a list of available commands.      
OPEN                         Open a connection to server.
QUIT                         Close all connections and quit.
EXIT                         Close all connections and quit.
LIST <server_path>           List information of a file or directory.
LS   <server_path>           List information of a file or directory.
RETR <server_path>           Retrieve a file from server.
GET  <server_path>           Retrieve a file from server.
STOR <local_path>            Store a file to server.
PUT  <local_path>            Store a file to server.
DELE <server_path>           Delete a file from server.
DEL  <server_path>           Delete a file from server.
RM   <server_path>           Delete a file from server.
CWD  <server_path>           Change working directory.
CD   <server_path>           Change working directory.
PWD                          Print working directory.
MKD  <server_path>           Make a directory recursively.
MKDI <server_path>           Make a directory recursively.
RMD  <server_path>           Remove a directory.
RMDI <server_path>           Remove a directory.
RMDA <server_path>           Remove a directory recursively.
```

#### 2.3 Client handler

To help the GUI work in a proper way, you need to launch an API server, which is called a client handler here.

```bash
python ./naive_ftp/client_handler/run.py
```

You should see something like:

```text
Serving on http://localhost:5000
```

#### 2.4 Client GUI

Finally, start the local server and check the GUI on <http://localhost:8181>.

```bash
cd app && node server.mjs
```

The server files and local files are located in `./server_files` and `./local_files` respectively by default. You may need to manually create them if not exist.

```bash
cd ..
mkdir -p server_files && mkdir -p local_files
```

By far, we support these features in our GUI:

- List the files in a directory.
  - Along with their names, sizes, types, last modified time, permissions and owners.
  - Hidden files will not be displayed.
  - *FTP command*: `LIST /dir_path`
- Change working directory to another path.
  - *FTP command sequence*: `CWD /dir_path`, `LIST /dir_path`
- Upload a file to server.
  - *FTP command*: `STOR /file_path`
- Download a file from server.
  - *FTP command*: `RETR /file_path`
- Create a new directory (recursively).
  - *FTP command*: `MKDIR /dir_path`
- Batch delete files and directories (recursively).
  - *FTP commands*: `DELE /file_path` or `RMDA /dir_path`

## How it works

In this chapter we will illustrate the entire communication process.

### 1 Client GUI

{{< image src="assets/mkdir.webp" caption="Create a directory using client GUI" >}}

To begin with, we suppose that a user is interacting with the client GUI in a browser, and performs an operation (e.g. create a directory).

### 2 Client GUI -> Client handler

The user operation is handled by the frontend, interpreted into some HTTP requests, and sent to the client handler (the API server).

{{< image src="assets/http-requests.webp" caption="Client GUI sends HTTP requests to client handler" >}}

### 3 Client handler -> Server -> Client handler

Next, the HTTP requests are processed by the client handler, interpreted into some FTP requests, and sent to the server. The server does some operations (creates a directory) according to the FTP requests, and then returns some FTP responses based on the status of these operations.

```text
Serving on http://localhost:5000
[INFO ] open_ctrl_conn: Connected to server.
[INFO ] cwd: Changed directory to: /
[INFO ] mkdir: Created directory: Hakula
```

We can see more details if we start the client handler in development mode (using command `flask run`).

```text
 * Serving Flask app "./naive_ftp/client_handler/client_handler.py" (lazy loading)
 * Environment: development
 * Debug mode: on
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 164-557-715
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
127.0.0.1 - - [08/Jan/2021 03:11:27] "OPTIONS /api/dir HTTP/1.1" 200 -
[INFO ] open_ctrl_conn: Connected to server.
[INFO ] cwd: Changed directory to: /
127.0.0.1 - - [08/Jan/2021 03:11:27] "POST /api/dir HTTP/1.1" 200 -
127.0.0.1 - - [08/Jan/2021 03:11:28] "GET /api/dir?path=%2F HTTP/1.1" 200 -
127.0.0.1 - - [08/Jan/2021 03:11:35] "OPTIONS /api/dir HTTP/1.1" 200 -
[INFO ] mkdir: Created directory: Hakula
127.0.0.1 - - [08/Jan/2021 03:11:35] "PUT /api/dir HTTP/1.1" 200 -
127.0.0.1 - - [08/Jan/2021 03:11:35] "GET /api/dir?path=%2F HTTP/1.1" 200 -
```

Besides, you may check the logs on the server to see how it reacts to the FTP requests.

```text
Welcome to Naive-FTP server! Press q to exit.
[INFO ] open_ctrl_sock: Server started, listening at ('192.168.56.1', 2121)
[INFO ] open_ctrl_conn: Accept connection: ('192.168.56.1', 53225)
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: CWD /
[DEBUG] cwd: Changing working directory to E:\Github\Naive-FTP\server_files
[INFO ] cwd: Changed working directory to /
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: LIST /
[DEBUG] ls: Listing information of E:\Github\Naive-FTP\server_files
[INFO ] open_data_sock: Data server started, listening at ('192.168.56.1', 53227)
[INFO ] open_data_conn: Data connection opened: ('192.168.56.1', 53228)
[INFO ] ls: Finished listing information of E:\Github\Naive-FTP\server_files
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: MKD Hakula
[DEBUG] mkdir: Creating directory: E:\Github\Naive-FTP\server_files\Hakula
[INFO ] mkdir: Created directory: E:\Github\Naive-FTP\server_files\Hakula
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: PING
[DEBUG] router: Operation: LIST /
[DEBUG] ls: Listing information of E:\Github\Naive-FTP\server_files
```

### 4 Client handler -> Client GUI

Finally, the responses from the server (sometimes along with data) are parsed into JSON format, and returned back to the client GUI. There may be some feedbacks shown in the client GUI to indicate whether the operation is successful or not.

You may try [Postman][postman] to inspect how the API works.

{{< image src="assets/postman.webp" caption="Test API using Postman" >}}

[postman]: https://www.postman.com

## TODOs

- Support more features
  - [ ] Rename files / directories.
  - [ ] Download a directory from server.
  - [ ] Batch download files / directories from server.
  - [ ] Upload a directory to server.
  - [ ] Batch upload files / directories to server.
  - [ ] Upload through selecting a file instead of manually inputting a path.
