# Morally Lucky (`stonk-morallylucky`)

> *"Where a significant aspect of what someone does depends on factors beyond his control, yet we continue to treat him in that respect as an object of moral judgment, it can be called moral luck."*
> Thomas Nagel, *Moral Luck* (1976)

**Morally Lucky** interrupts your trading career with moral dilemmas drawn from real philosophy. Every choice has an immediate effect, followed days or weeks later by a consequence that **luck** decides. The same decision can make you a hero or send you to prison. You'll never know in advance which one you're making.

> [!WARNING]
> **Mature themes (PG-13/R):** crime, violence, drugs, drunk driving, infidelity and blackmail, assisted dying, and child labour. Nothing explicit, but this isn't a family mod.
>
> **It can wreck your save:** jail sentences of up to a year, hospital stays, losses of a quarter of your fortune or more, collapsing companies, and **market-wide crashes** that hit every portfolio in the city. Some outcomes are huge windfalls instead.

## How it plays

- Once you're past day 10, each day has a small chance to bring a dilemma, with at least two weeks between dilemmas. Nothing appears while you're in jail, in hospital, on holiday or in a story scene.
- A dilemma opens as a normal in-game choice dialog. When it involves one of your contacts, their portrait appears with it.
- Your choice has an **immediate** effect, then a **delayed consequence** a few days to a few weeks later. Luck decides the consequence. Delayed consequences survive saving and loading.
- Money at stake scales with your wealth, so dilemmas matter just as much at 10 million as at 10 billion.
- Every choice is recorded in your **moral ledger** under a school of thought. After every third choice, *Know Thyself* tells you which tradition you're drifting toward.

## The dilemmas

| Dilemma | Thought experiment |
| --- | --- |
| **The Trolley Desk** | Philippa Foot & Judith Jarvis Thomson's trolley problem, as a runaway sell algorithm |
| **The Ring of Gyges** | Plato, *Republic* II: would you stay just if you were invisible? |
| **The Lotus Eaters** | Robert Nozick's experience machine, as a too-perfect drug |
| **The Drowning Child** | Peter Singer, *Famine, Affluence, and Morality* |
| **Gauguin's Gamble** | Bernard Williams' Gauguin: is a choice justified by how it turns out? |
| **The Two Drivers** | Thomas Nagel's two drunk drivers, separated only by luck |
| **A Small Leviathan** | Thomas Hobbes' *Leviathan*, as a protection racket |
| **Merely as a Means** | Kant's formula of humanity, with compromising photographs |
| **The Ones Who Walk Away** | Ursula K. Le Guin's Omelas, and the market built on it |
| **Pascal's Tithe** | Pascal's wager, collected by a cult |
| **The Double Effect** | Aquinas' doctrine of double effect, at a deathbed |
| **The Prisoner's Dilemma** | Flood, Dresher & Tucker's game, in two interrogation rooms |

## The moral ledger

| School | Thinkers it draws on |
| --- | --- |
| Consequentialism | Bentham, Mill, Singer |
| Deontology | Kant, Ross |
| Virtue ethics | Aristotle, Plato |
| Will to power | Nietzsche, Machiavelli, Thrasymachus |
| Ethics of care | Gilligan, Noddings |

## Keys

| Key | Action |
| --- | --- |
| **F7** | Force a dilemma now (for testing, or if you're impatient for disaster) |
| **Shift+F7** | Show your moral ledger |

## Tuning

The top of `stonk-morallylucky.meow` has a few values you can edit:

| Value | Default | Meaning |
| --- | --- | --- |
| `ML_CHANCE` | `5` | % chance of a dilemma each day, once the cooldown has passed |
| `ML_COOLDOWN` | `14` | Minimum days between dilemmas |
| `ML_FIRST_DAY` | `10` | No dilemmas before this game day |
| `ML_PROFILE_EVERY` | `3` | Show the ledger after every N choices |

## Installation

1. Copy [`stonk-morallylucky.meow`](stonk-morallylucky.meow) into the game's `mods` folder.
2. Start the game and enable **Morally Lucky** in the Mods menu.
3. Play, or press **F7** to meet your first dilemma.

The mod saves its ledger with your game. Turning it off just stops new dilemmas. Consequences already scheduled in a save are skipped while the mod is off.
