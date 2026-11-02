# 🌱Open-Source Plant Game

**Discover plants. Grow your garden. Build a shared botanical world.**

This is an open-source plant exploration and collection game that combines real-world botanical discovery with 3D gardening, plant identification, observation journals, and community-driven scientific data. Players will be able to discover plants outdoors, document their features, build personal gardens, and contribute to a growing plant database.

> **Project status:** Early design and development. The gameplay systems and database architecture are being designed; the features described below are planned unless otherwise stated.

## 🌿 Gameplay

1. **Explore and discover** — Find plants in the real world and photograph them.
2. **Identify and document** — Use planned AI-assisted identification and guided photo tasks to record plant characteristics.
3. **Collect and grow** — Add plants to a personal 3D garden and care for them.
4. **Observe and learn** — Keep plant diaries with notes, photos, and customizable layouts.
5. **Earn and collaborate** — Complete challenges, earn in-game rewards, and contribute useful botanical records.
6. **Share and trade** — Visit gardens, exhibit collections, collaborate with other players, and trade plants using in-game currency.

## ✨ Planned Features

- **Plant identification and 3D modeling:** Photograph roots, stems, leaves, flowers, and other structures; follow guided capture tasks and create plant models.
- **Personal 3D gardens:** Customize a garden, cultivate collected plants, and display discoveries.
- **Shared botanical collection:** Explore a central botanical garden organized by environments such as tropical, subtropical, mountain, and plateau habitats.
- **Plant encyclopedia:** Browse species information, images, and identification references.
- **Plant diaries:** Record observations and growth with text, images, and flexible layouts.
- **Quests and progression:** Earn experience, virtual currency, titles, and contribution recognition.
- **Ecological events:** Discover seasonal changes, time-limited plants, and biome-specific events.
- **Community features:** Join teams and communities, visit gardens, exhibit specimens, and participate in virtual plant trading.
- **Cultivation and breeding:** Experiment with game-level plant traits while keeping scientific species records separate.

## 🗃️ Database Design

The game is designed around **PostgreSQL (15+ recommended)**, with proposed use of JSONB, UUIDs, enums, and potentially PostGIS for geographic data.

The database is organized into six layers:

| Layer | Purpose |
| --- | --- |
| Species | Botanical taxonomy, species traits, scientific references, and encyclopedia entries |
| Individual plants | Player-owned plants, uploaded media, cultivation, and breeding |
| Assets | Virtual currency, transactions, trading, loans, and harvest rewards |
| Contributions | Discovery credit, reviews, reputation, quests, and rankings |
| Interactions | Exhibitions, teams, communities, specimen halls, and plant diaries |
| Maps & ecology | Biomes, map versions, seasonal cycles, and ecological events |

A key design principle is to **keep scientific species data separate from game-specific plant states**, allowing the botanical database to remain traceable and potentially useful for future research.

## 🛠️ Development Status

The project is currently focused on requirements, gameplay design, and database architecture. Existing design materials include a database specification, gameplay concepts, and a three-page interface concept covering discovery, plant analysis, and collection.

**Next priorities:**

- Finalize the collection and observation data structures.
- Complete the professional observation and capture workflows.
- Implement and test the core discover → identify → collect → journal loop.
- Develop playable 3D garden and community features in later stages.

There is **no confirmed public playable release** at this stage.

## 🤝 Contributing

This game aims to grow through open collaboration. Contributions to database design, botanical data quality, gameplay systems, interface design, documentation, and testing are welcome as development progresses.

For now, please use GitHub Issues to suggest improvements or discuss ideas if Issues are enabled in this repository.

## 📄 License

A license has not yet been specified. Please check the repository for a `LICENSE` file before assuming permissions to reuse or redistribute its contents.

---

*We aim to make learning about plants an ongoing adventure — one discovery at a time.*
