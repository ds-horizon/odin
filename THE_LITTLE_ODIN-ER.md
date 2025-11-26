# The Little Odin-er

This little guide is inspired by the timeless classic [The Little LISPer](https://en.wikipedia.org/wiki/The_Little_Schemer), a book that taught generations of programmers through playful questions, patient answers, and a spirit of curiosity.

In that same spirit, *The Little Odin-er* is not a manual. It's a conversation. Between you and Odin. Together, we'll explore the core ideas that make Odin tick: environments, services, components, deployments, and more.

There are no prerequisites, no heavy jargon, and no need to rush. Just simple questions, one after another, building insight step by step.

So open your mind, bring your curiosity, and let's begin.

---

## Environment

**Q: What's the first thing you need before anything can run?**

A: An environment.

**Q: Why?**

A: Because a service cannot exist on its own. It needs a place to live in.

**Q: So, is an environment like a machine?**

A: Not exactly. It's more like a logical space where services run, kind of like a `world` for services.

**Q: How many services can you have in an environment?**

A: As many as you like. But no two services with the same name. Duplicates aren't allowed.

**Q: Are all environments isolated?**

A: Not yet, but we're getting there.

**Q: How long does an environment live?**

A: By default, it lives for 7 days.

**Q: What happens after 7 days?**

A: It's automatically deleted, along with all the services deployed in it.

**Q: Can I make it last longer?**

A: Yes, you can extend the environment lifetime.

---

## Service

**Q: What does an environment host?**

A: Services.

**Q: And what's a service?**

A: A purposeful unit made of components.

**Q: How does it interact with the world?**

A: Using classic TCP via service interfaces like HTTP APIs, messaging endpoints, etc.

**Q: Do I need to know how it works inside?**

A: No. You just talk to its interface using the right protocol.

---

## Component

**Q: What makes up a service?**

A: Components.

**Q: What's a component?**

A: It can be a single process or a group of tightly coupled processes that act as one.

**Q: Can a component live on its own?**

A: Nope. It must always belong to a service.

**Q: Give me examples.**

A: A REST application, MySQL cluster, Aerospike cluster, etc. All are components.

---

## Service Boundary

**Q: If I define a service, does that create a boundary?**

A: Yes. That's your service boundary.

**Q: What's inside it?**

A: All its components.

**Q: And what's outside?**

A: Everything else.

---

## Service Definition

**Q: How do I tell Odin what my service is?**

A: Through a service definition.

**Q: What's in a service definition?**

A: The service name, version, team, and a list of components and their configs.

**Q: Where do these definitions live?**

A: In a central repository called service definitions.

---

## Deploy and Operate

**Q: What does it mean to deploy something?**

A: It means making something exist in an environment that wasn't there before.

**Q: Like deploying a service for the first time?**

A: Exactly.

**Q: And what happens after it's deployed successfully?**

A: You operate it, scale it, maybe undeploy it.

**Q: Can you deploy it again in the same environment?**

A: No, it's already there.

**Q: But what if I want to change it, like upgrade a component or the whole service?**

A: That's part of operating it. You update what's already there, not deploy it again from scratch.

---

## Artefacts Management

**Q: How does Odin get a service's code?**

A: It doesn't. It assumes the artefact is already in the artefactory.

**Q: Who pushes artefacts to the artefactory?**

A: Service owners. Odin doesn't get involved in that part.

**Q: So, when does Odin step in?**

A: Once the artefact is ready, Odin bakes the image and deploys it.
