# Technical names

Issue 9 calls these **technical nouns** (TN, rules 1.5 to 1.11) and **technical verbs** (TV, rules 1.12
and 1.13). They are not in the dictionary. Use a word that is not in the dictionary, or a word that the
dictionary does not approve, only as a technical name from this list, or as a new proposed term
(SKILL.md, step 4).

Rules for this list:

- Use a technical noun only as a noun (rule 1.7). Use a technical verb only as a verb (rule 1.13).
- Use one technical noun for one item (rule 1.11). The term before the colon is the term to use. The words
  after "Not:" are synonyms that you must not use for the same item.
- A technical verb obeys the verb rules of section 3: no "-ing" forms and no perfect tenses.
- An "-ing" word is permitted only as a technical noun or in one (rule 3.5). It must be in this list.
- Add a term only when the user approves it, in a change to this file. Then move it from "Proposed" to the applicable approved
  section. If the user rejects a term, move it to "Rejected terms" with the approved words to use.
  `scripts/check_ste.py` reads this file. It shows proposed terms as notes (`--notes`), not as findings.

Format: `- term: meaning. Not: synonym, synonym.` The meaning limits the term. Use the term only with this meaning.

## Technical nouns, approved for software work

- branch
- commit
- endpoint
- pipeline
- merge request: GitLab item that asks to merge one branch into a different branch. Not: MR, pull request, PR.
- repository: Git store of the files and history of one project. Not: repo.
- worktree: Additional Git working directory of one repository. Not: working copy.
- tenant: Airline or airport brand with its own storefront, for example aea or vlg.
- service: Software that operates independently and gives an API to other software. Not: app, microservice.
- server: Software or computer that sends responses to client requests. Not: backend.
- client: Software that sends requests to a server. Not: caller, consumer.
- user: Person or account that uses the software. Not: end user.
- cluster: Group of computers that Kubernetes controls as one system. Not: group of nodes.
- namespace: Named scope that keeps Kubernetes objects apart. Not: scope.
- pod: Smallest unit that Kubernetes runs. Not: instance.
- container: Isolated process that runs from a container image. Not: box.
- image: Container image, or a product picture file. Not: picture.
- deployment: Installation of a version on a stage, or a Kubernetes Deployment object. Not: rollout.
- release: Published version of a product that has a number. Not: rollout.
- version: Numbered state of software or of a file. Not: edition.
- tag: Named marker on a Git commit or on a container image. Not: marker.
- build: Compiled and packaged code, or the procedure that makes it. Not: compilation.
- job: GitLab CI or Kubernetes unit of work that has a name.
- stage: One environment of a project (`latest`, `review`, `uat`, `preprod`, `prod`), or a GitLab CI stage. Not: environment, phase.
- unit test: Automatic test of one function or module. Not: module test, component test.
- integration test: Automatic test of parts that operate together. Not: system test.
- test case: One specified check with input data and an expected result. Not: test scenario.
- bug: Fault in software that causes incorrect operation. Not: issue.
- error message: Text that software shows or records after a failure. Not: fault message.
- log: Record of occurrences that software writes. Not: trace.
- log file: File that holds a log. Not: logfile.
- message: Data that software sends to other software, for example through RabbitMQ. Not: notification.
- queue: RabbitMQ store that holds messages in sequence. Not: buffer.
- event: Data that tells that a change occurred. Not: notification, signal.
- request: Message that a client sends to a server, for example HTTP. Not: call.
- response: Message that a server sends back to a client. Not: reply, answer.
- query: Request for data that you send to a database or a GraphQL API. Not: data request, lookup.
- schema: Formal definition of the structure of a database or a GraphQL API. Not: data model, structure definition.
- string: Data type for a sequence of characters. Not: char sequence, text value.
- variable: Named storage location for a value in code. Not: var, placeholder.
- parameter: Named input that a function, command, URL or query declares. Not: param, argument, arg.
- function: Named block of code that does one task, including a method. Not: routine, func.
- class: Code template that defines the fields and behavior of objects. Not: object type.
- module: Unit of code that you build, version and publish together, such as a Go module. Not: component.
- package: Group of code files that you compile or install together. Not: bundle, pkg.
- dependency: Library or module that other code needs. Not: dep, requirement.
- library: Set of reusable code that other code calls. Not: lib.
- script: File with commands that a shell or interpreter runs. Not: batch file.
- command: Text instruction that you enter in a shell or CLI.
- flag: Command-line switch, such as -race. Not: option, command-line option, switch.
- configuration file: File that holds the settings of a program. Not: config file, config.
- environment variable: Named value that a process reads from its environment. Not: env var, env.
- secret: Credential value, such as a password or API key, kept in Vault or a Kubernetes Secret. Not: credential, confidential value.
- cache: Fast store of copied data for later use. Not: temporary store, buffer.
- timeout: Maximum wait time for an operation, and the stop at that limit. Not: time limit.
- null: Value that means no value. Not: none.
- exception: Error object that a program throws at run time. Not: fault.
- stack trace: List of function calls at the moment of an error. Not: backtrace, traceback.
- API: Interface that programs use to communicate with each other. Not: web service.
- GraphQL: Query language and API style used by the platform. Not: graph API.
- reviewer: Person who examines and approves a change. Not: approver, checker.
- review comment: Note that a reviewer writes on a merge request. Not: remark, feedback.
- line: One row of text or code in a file. Not: row.
- skill: File of instructions that an agent loads. Not: instruction file.
- prompt: Text that you send to an AI model. Not: input.
- subagent: Agent that a different agent starts to do one task. Not: sub-agent, child agent.
- workflow: Script that starts a set of agent steps in a sequence. Not: flow, automation.
- session: One continuous agent chat with its own history. Not: conversation, chat.
- sandbox: Isolated area that limits file and network access of a command. Not: jail.
- order: Record of a customer purchase in the platform (OMS). Not: purchase, sale.
- price: Quantity of money that a customer pays for an item. Not: cost.
- cart: Items that a customer selected to buy. Not: basket, bag.
- checkout: Steps where a customer pays for the cart. Not: payment page, purchase flow.
- export: File or data set that a system writes for use outside it, for example a CSV file of orders. Not: dump, extract.
- export job: Background job that creates an export. Not: export process.
- production: The `prod` stage, which customers use. Not: live.
- migration: Versioned script that changes a database schema or its data. Not: schema change, DB update.
- handler: Code that processes one request or message.
- context: Go value (context.Context) that carries a deadline and a cancel signal. Not: ctx.
- goroutine: Go function that operates at the same time as other functions. Not: thread, green thread.
- mutex: Lock that lets only one goroutine use shared data at a time. Not: semaphore.
- map: Data structure of key and value pairs. Not: hashmap.
- data race: Two goroutines access the same memory at the same time, and one of them writes. Not: race.
- nil: Go value of a pointer, slice, map or interface that refers to nothing.
- panic: Go runtime error that stops the goroutine unless code recovers it. Not: crash.
- feature flag: Setting that turns a feature on or off. Not: feature toggle, feature switch.
- timestamp: Stored value that shows a date and time. Not: time stamp, datetime.
- port: Number that identifies one network service on a host. Not: socket.
- directory: Named container for files in a file system. Not: folder.
- runtime: Software layer that operates a program (Go runtime, JVM). Not: execution environment, run time.
- race condition: Defect where the result depends on the timing of operations. Not: timing bug.
- text: Written words or characters in a file, field or message. Not: wording.
- comment: Written remark in code, on a merge request or on a TargetProcess item. Not: remark.
- list: Items written or stored one after the other. Not: enumeration.

## Technical verbs, approved for software work

- merge: Add the commits of one branch to a different branch. Not: combine, integrate, land, join.
- rebase: Put the commits of a branch on top of a different base commit. Not: replay, re-apply.
- compile: Change source code into machine code or a binary file. Not: translate.
- parse: Read text or bytes and change them into a data structure. Not: interpret, analyze.

## Technical nouns, from STE100 category 19 (computer science and ICT)

These are the examples that Issue 9 gives for category 19 (rule 1.5).

- add-in
- add-on
- AI
- arrow
- artificial intelligence
- authentication
- backup
- backup file
- bookmark
- chatbot
- content
- cursor
- cybersecurity
- database
- dialog check box
- digitalization
- digitization
- e-mail
- embedding
- field
- file
- firewall
- hallucination
- HTML
- icon
- interface
- internet
- laptop
- large language model
- local operation
- machine learning
- memory
- menu
- metadata
- mouse
- network
- operating system
- phone
- plug-in
- pre-loaded software
- preset value
- prompt engineering
- remote operation
- screen
- search engine
- smartphone
- status bar
- store
- tablet
- token
- toolbar
- touchscreen
- tuning
- update
- voice mail
- XML

## Technical verbs, from STE100 category 2 (computer processes and applications)

These are the examples that Issue 9 gives for technical verb category 2 (rule 1.12).

- click
- digitize
- enter
- press
- print
- swipe
- tap
- type
- clear
- close
- copy
- cut
- delete
- deselect
- disable
- drag
- enable
- encrypt
- erase
- filter
- highlight
- invalidate
- maximize
- minimize
- navigate
- open
- paste
- save
- scroll
- sort
- store
- validate
- abort
- boot
- communicate
- debug
- download
- format
- install
- load
- manage
- process
- reboot
- update
- upgrade
- upload

## Proposed technical nouns

Not approved yet. The user must approve or reject each term. None at this time.

## Proposed technical verbs

Not approved yet. The user must approve or reject each term. None at this time.

## Rejected terms

Do not use these words as technical names. Use the approved words that the line gives.

### Nouns

- test: Use TEST (n): 'Add a test for the empty cart.' For the verb, write 'Do a test of the handler.' Do not write 'Test the handler.'
- logging: 'Change the log level.' 'The handler records the error in the log.' 'Use the log library.'
- argument: Use 'parameter' and VALUE (n): 'The script has two parameters: the tenant and the date.' 'Give the value 30 for the timeout parameter.' Error text such as 'wrong number of arguments' stays as quoted text.
- option: Choice: 'You have two alternatives.' Command switch: 'Add the -race flag.' Configuration key: 'Set the timeout field in the configuration file.'
- config file: Use 'configuration file': 'Edit the configuration file.'
- caching: Use 'cache': 'Disable the cache.' 'The cache can keep old data.'
- retry: Use TRY (v) and AGAIN (adv): 'The job tries again a maximum of 3 times.' Keys such as 'retry' stay as code text.
- type: Use TYPE (n), already approved: 'The type of the price field is string.'
- code review: Use EXAMINE (v) and 'reviewer': 'A reviewer must examine the change. Then you can merge it.'
- diff: Use CHANGE (n): 'Read the changes in the merge request.' Write `git diff` only as a command in code format.
- staging: Use the stage name from GLOSSARY.md as quoted text: STE: "If DATABASE_URL identifies the `preprod` database, `make migrate` deletes the data." Or: "the `uat` stage".

### Verbs

- push: Send the commits to GitLab. Or: Upload branch fix-x to the remote repository. (SEND is approved; UPLOAD is a category 2c technical verb.)
- pull: Get the new commits from main. Or: Download the new commits from the remote repository. (GET is approved; DOWNLOAD is category 2c.)
- commit: Put the changes in a commit. Or: Make a commit with the changes.
- deploy: Deploy version 2 to the `uat` stage. (DEPLOY is an approved dictionary verb. Use it with its dictionary meaning.)
- build: Make the Docker image. Or: The pipeline makes the frontend package.
- run: Do the unit tests. Or: Start the job. Or: The service operates in the cluster.
- execute: Start the script. Or: Type the command make lint.
- restart: Stop the service. Then start it again. Or: Reboot the server. (REBOOT is category 2c, for a computer only.)
- retry: Try the request again. Or: Start the job again.
- revert: Make a commit that removes the changes of commit abc123. Or, in a review: Put back the previous code in handler.go.
- cherry-pick: Copy commit abc123 to the release branch. (COPY is a category 2b technical verb.)
- refactor: Change the structure of the code. Do not change what it does.
- lint: Examine the code with golangci-lint. (Tool names stay as they are.)
- cache: Keep the result in the cache.
- query: Send a query to the database. Or: Read the orders from the database.
- render: The browser shows the page. Or: The server makes the HTML. Or: React updates the component after each state change.
- configure: Set the timeout in the configuration file. Or: Set the environment variable `DB_HOST`.
- authenticate: The gateway uses the token for authentication of the client.
- review: Examine the changes in the merge request.
- approve: Give your approval to the merge request. Or: Click Approve. (UI labels stay as they are.)
- fetch: Get the new commits from the remote repository. Or: The client gets the price from the API.
- clone: Make a local copy of the repository. Or: Download the repository.
- check out: Select branch fix-x with git switch fix-x. Or, for 'look at': Examine the log.
- call: The handler uses Close() at the end of the function. Or: The loop sends three requests to the payment API.
- return: FindOrder gives nil if it cannot find the order. Or: The API sends status 404.
- export: Write the orders to a CSV file. Or: Save the data in a CSV file.
- import: Load the exchange rates from the CSV file.
- migrate: Move the data to the new database. Or: Do the migration.
- lock: Do not let other goroutines change the data until the function ends. Or: Use mu.Lock() before you write to the map.
- unlock: Release the mutex. Or: Let other goroutines change the data again.
- panic: The handler causes a panic if the map is nil.
