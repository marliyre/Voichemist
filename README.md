<div align="center">

<img width="7680" height="3213" alt="Banner Game (1)" src="https://github.com/user-attachments/assets/cf44f479-fb16-4c52-8fcf-ad16ec79a41a" />

***A Tactical Alchemy 2D Arcade Game featuring Medieval/Fantasy Anomaly Eradication***



![GitHub release (latest by date)](https://img.shields.io/badge/Status-In_Development-amber?style=for-the-badge)
![Engine](https://img.shields.io/badge/Engine-Godot-blue?style=for-the-badge&logo=unity)
![Genre](https://img.shields.io/badge/Genre-Strategy_--_Crafting_--_Turn--Based_Combat_--_2D_--_PC-purple?style=for-the-badge)

<p align="center">
  <a href="#-about-the-game">About</a> •
  <a href="#-core-gameplay">Gameplay</a> •
  <a href="#-anomaly-hierarchies">Anomalies</a> •
  <a href="#-alchemical-arsenal">Arsenal</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#download">How to Download?</a>
</p>

---

</div>

## 📜 About The Game

> *"Melalui maklumat Magisterium Arcane dan Dewan Tinggi, pembawa dokumen ini resmi menempuh jalan alkimia mistis. Di tengah ancaman entropi kegelapan, Anda dipanggil untuk membuktikan tekad dengan menguasai penyulingan Viexir, peracikan Azer, dan taktik bertahan hidup."*

**Voichemist** adalah gim *2D Arcade/Tactical Shooting* bertema *medieval fantasy*. Pemain berperan sebagai seorang *Initiate* yang bertugas membuat alat, meracik ramuan alkimia, mengalkulasikan arah dan tenaga lemparan amunisi untuk membasmi berbagai wujud anomali yang mengancam tatanan alam.

Dikembangkan dengan pendekatan **UI-based exploration** dan **arcade physics combat** (serupa dengan mekanik *Worms* & *Perjuangan Semut*), gim ini berfokus pada kedalaman taktis, manajemen sumber daya, dan atmosfer yang imersif tanpa membebani performa perangkat.

---

## 🎮 Core Gameplay

Gim ini terbagi menjadi empat fase utama yang saling mendukung:

```
[ Basecamp & Exploration ] ───(Crafting, Brewing, & Tile Map)───► [ Arcade Battle Phase ]
          ▲                                                                  │
          └───────────────────────(Reward & Materials)───────────────────────┘
```

1. **Tile-Based Exploration (UI-Based):**
   * Pemain menelusuri peta ubin (*Tile Map*), mulai dari *spawn* awal (*Basecamp*) menuju zona sumber daya, peti, atau anomali.
   * Mengatur *risk vs reward* saat memilih jalan ekspedisi: *Resource Tiles*, *Mystery Chest*, atau *Battle Encounter*.

2. **Arcade Tactical Battle:**
   * Pertarungan *turn-based 2D* menggunakan sistem kalkulasi sudut trajektori dan daya dorong lemparan.
   * Memanufaktur proyektil utama (**Viexir**) dan alat pendukung sesuai jenis anomali yang dihadapi.

---

## 👾 Anomaly Hierarchies

Nama anomali di dalam permainan ini adalah The Wanderers yang dikategorikan menjadi 3 tingkat:

| Klasifikasi | HP | Attack Damage | Deskripsi & Mekanik |
| :--- | :--- | :--- | :--- |
| **Common** | 190 | 12 | Makhluk anomali tingkat dasar yang sering berkeliaran. Berpeluang tingkat rendah dalam memberikan efek *poison*. |
| **Rare** | 340 | 20 | Makhluk anomali yang menyerang secara berkelompok. Berpeluang tingkat sedang dalam memberikan efek *poison*. |
| **Epic** | 500 | 25 | Anomali raksasa tingkat tinggi yang merusak peralatan. Berpeluang tingkat tinggi dalam memberikan efek *poison*. |

---

## 🧪 Alchemical Arsenal

### 💥 The Big 3 Projectile

### Offense Viexir (Viexir Serang) - Primary Projectile (Damage Dealer)
<div align="left">

<img width="200" alt="(1) Viexir Serang" src="https://github.com/user-attachments/assets/b38f65fe-ef61-416d-a46c-f2f830305beb" />

</div>

Proyektil alkimia volatil yang berfungsi sebagai senjata penghasil *damage* utama bagi para Voichemist untuk membasmi anomali.

### Neutralize Viexir (Viexir Netralisir) - Secondary Projectile (Debuff/Purification)
<div align="left">

<img width="200" alt="(1) Viexir Netralisir" src="https://github.com/user-attachments/assets/996471d7-45bc-4422-906d-4776b1c62fbc" />

</div>

Proyektil alkimia volatil yang berfungsi sebagai senjata pengurang kekuatan anomali sekaligus menangani akumulasi *poison*.

### Defense Viexir (Viexir Tahan) - Secondary Projectile (Defensive/Counter)
<div align="left">

<img width="200" alt="(1) Viexir Tahan" src="https://github.com/user-attachments/assets/265cc0b7-0cb6-4698-9138-7022b59c935a" />

</div>

Proyektil alkimia volatil yang berfungsi sebagai senjata pemantul serangan anomali kepada sumbernya.

### 🛡️ Utility Potions
* **Vitae** *(Heal Potion)* — Merajut kembali jaringan tubuh yang rusak akibat serbuan miasma dan racun.
<div align="left">

<img width="200" alt="Potion Heal" src="https://github.com/user-attachments/assets/1e6d8ebf-7b4e-487b-802c-225180e1b048" />

</div>

* **Umbra** *(Invisible Potion)* — Menyemprotkan selubung bayangan untuk menyamarkan wujud dan suhu tubuh dari kejauhan.
<div align="left">

<img width="200" alt="Potion Invisible" src="https://github.com/user-attachments/assets/e7ce0c1e-f7ea-41a9-b805-87d987439d86" />

</div>

* **Vigor** *(Stamina Potion)* — Memacu denyut nadi dan memulihkan daya tahan fisik untuk memperpanjang jalan ekspedisi.
<div align="left">

<img width="200" alt="Potion Stamina" src="https://github.com/user-attachments/assets/1cc7443c-4603-44ee-a650-320e19696f03" />

</div>

* **Zephyr** *(Wind Potion)* — Mendatangkan keberuntungan melalui hembusan angin yang mengganggu lintasan proyektil anomali.
<div align="left">

<img width="200" alt="Potion Wind" src="https://github.com/user-attachments/assets/9a6a9865-34cd-4f15-9f23-c0cbfe02f01c" />

</div>

---

## 🛠️ Tech Stack & Assets

* **Game Engine:** Godot
* **UI & Visual Design:** Adobe Illustrator & ibisPaint X
* **Scripting Language:** GDScript

---

<a name="roadmap"></a>

## 🗺️ Development Roadmap

- [x] Konseptualisasi Lore & Desain Anomali
- [x] Standardisasi Sistem Alkimia & Proyektil (Viexir)
- [x] Perancangan UI Cooldown System
- [x] Implementasi Sistem Eksplorasi *Tile-Based* (Grid/Pathing)
- [x] Prototipe Mekanik Lemparan Fisika 2D (Arcade Battle)
- [ ] Integrasi Audio & Visual Polish (Sunburst Reward FX)

---

<a name="download"></a>

## ⚠️ How to Download?

* **Step 1:** Godot
* **Step 2:** Adobe Illustrator & ibisPaint X
* **Step 3:** GDScript

---

<div align="center">

<img width="500" alt="Logo No Text" src="https://github.com/user-attachments/assets/5f3daff5-5a55-40e6-b8ea-44611dde0a73" />

*A Project by **Absurd Team***

</div>
