(() => {
  "use strict";

  const $ = (id) => document.getElementById(id);
  const reduceMotionQuery = window.matchMedia(
    "(prefers-reduced-motion: reduce)",
  );
  const finePointerQuery = window.matchMedia("(pointer: fine)");
  let reduceMotion = reduceMotionQuery.matches;

  /* Canvas Qi Effects */

  const canvas = $("qiCanvas");
  const ctx =
    canvas && canvas.getContext ? canvas.getContext("2d") : null;
  let cW = 0;
  let cH = 0;
  let particles = [];
  let canvasRAF = 0;
  let auraRAF = 0;
  let mouseX = -1000;
  let mouseY = -1000;

  function resizeCanvas() {
    if (!canvas || !ctx) return;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    cW = window.innerWidth;
    cH = window.innerHeight;
    canvas.width = Math.floor(cW * dpr);
    canvas.height = Math.floor(cH * dpr);
    canvas.style.width = cW + "px";
    canvas.style.height = cH + "px";
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    createParticles();
  }

  class SpiritMote {
    constructor() {
      this.reset(true);
    }

    reset(randomY = false) {
      this.x = Math.random() * cW;
      this.y = randomY ? Math.random() * cH : cH + Math.random() * 100;
      this.size = 0.8 + Math.random() * 2.2;
      this.speedY = -(0.2 + Math.random() * 0.5);
      this.speedX = (Math.random() - 0.5) * 0.3;
      this.opacity = 0;
      this.maxOpacity = 0.22 + Math.random() * 0.55;
      this.life = 520 + Math.random() * 700;
      this.age = Math.random() * this.life;

      const t = Math.random();
      if (t < 0.4) {
        this.r = 111;
        this.g = 174;
        this.b = 144;
      } else if (t < 0.72) {
        this.r = 216;
        this.g = 181;
        this.b = 108;
      } else if (t < 0.92) {
        this.r = 163;
        this.g = 217;
        this.b = 255;
      } else {
        this.r = 209;
        this.g = 86;
        this.b = 94;
      }
    }

    update() {
      this.age++;
      this.x += this.speedX + Math.sin(this.age * 0.01) * 0.2;
      this.y += this.speedY;

      if (mouseX > -500) {
        const dx = this.x - mouseX;
        const dy = this.y - mouseY;
        const dist = Math.hypot(dx, dy);
        if (dist > 0 && dist < 150) {
          const force = (150 - dist) / 150;
          this.x += (dx / dist) * force * 1.5;
          this.y += (dy / dist) * force * 1.5;
        }
      }

      const progress = this.age / this.life;
      if (progress < 0.15) {
        this.opacity = (progress / 0.15) * this.maxOpacity;
      } else if (progress > 0.75) {
        this.opacity = ((1 - progress) / 0.25) * this.maxOpacity;
      } else {
        this.opacity = this.maxOpacity;
      }

      if (
        this.age >= this.life ||
        this.y < -24 ||
        this.x < -24 ||
        this.x > cW + 24
      ) {
        this.reset();
      }
    }

    draw() {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(${this.r},${this.g},${this.b},${this.opacity})`;
      ctx.fill();

      if (this.size > 1.5) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size * 3.5, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${this.r},${this.g},${this.b},${this.opacity * 0.18})`;
        ctx.fill();
      }
    }
  }

  function createParticles() {
    if (!ctx || reduceMotion) return;
    const count = Math.min(72, Math.max(28, Math.floor(cW / 18)));
    particles = Array.from({ length: count }, () => new SpiritMote());
  }

  function animateCanvas() {
    if (reduceMotion || document.hidden || !ctx) {
      canvasRAF = 0;
      return;
    }

    ctx.clearRect(0, 0, cW, cH);

    for (let i = 0; i < particles.length; i++) {
      const a = particles[i];
      a.update();
      a.draw();

      for (let j = i + 1; j < particles.length; j++) {
        const b = particles[j];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const dist = Math.hypot(dx, dy);

        if (dist < 105) {
          const alpha =
            (1 - dist / 105) * Math.min(a.opacity, b.opacity) * 0.42;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.strokeStyle = `rgba(216,181,108,${alpha})`;
          ctx.lineWidth = 0.7;
          ctx.stroke();
        }
      }
    }

    canvasRAF = requestAnimationFrame(animateCanvas);
  }

  function startCanvas() {
    if (reduceMotion || document.hidden || !ctx || canvasRAF) return;
    if (!particles.length) {
      resizeCanvas();
    }
    canvasRAF = requestAnimationFrame(animateCanvas);
  }

  function stopCanvas() {
    if (canvasRAF) cancelAnimationFrame(canvasRAF);
    canvasRAF = 0;
    if (ctx) ctx.clearRect(0, 0, cW, cH);
  }

  /* Cursor Aura */

  const cursorAura = $("cursorAura");
  let auraX = -1000;
  let auraY = -1000;

  function animateAura() {
    if (
      reduceMotion ||
      document.hidden ||
      !cursorAura ||
      !finePointerQuery.matches
    ) {
      auraRAF = 0;
      return;
    }

    auraX += (mouseX - auraX) * 0.08;
    auraY += (mouseY - auraY) * 0.08;
    cursorAura.style.left = auraX + "px";
    cursorAura.style.top = auraY + "px";
    auraRAF = requestAnimationFrame(animateAura);
  }

  function startAura() {
    if (
      reduceMotion ||
      document.hidden ||
      !cursorAura ||
      !finePointerQuery.matches ||
      auraRAF
    ) {
      return;
    }
    auraRAF = requestAnimationFrame(animateAura);
  }

  function stopAura() {
    if (auraRAF) cancelAnimationFrame(auraRAF);
    auraRAF = 0;
  }

  document.addEventListener(
    "mousemove",
    (event) => {
      mouseX = event.clientX;
      mouseY = event.clientY;
    },
    { passive: true },
  );

  window.addEventListener("resize", resizeCanvas, { passive: true });

  document.addEventListener("visibilitychange", () => {
    if (document.hidden) {
      stopCanvas();
      stopAura();
    } else {
      startCanvas();
      startAura();
    }
  });

  if (reduceMotionQuery.addEventListener) {
    reduceMotionQuery.addEventListener("change", (event) => {
      reduceMotion = event.matches;
      if (reduceMotion) {
        stopCanvas();
        stopAura();
      } else {
        resizeCanvas();
        startCanvas();
        startAura();
      }
    });
  }

  if (!reduceMotion) {
    resizeCanvas();
    startCanvas();
    startAura();
  }

  /* Card hover glow */

  document.querySelectorAll(".principle-card").forEach((card) => {
    card.addEventListener("mousemove", (event) => {
      const rect = card.getBoundingClientRect();
      card.style.setProperty(
        "--gx",
        ((event.clientX - rect.left) / rect.width) * 100 + "%",
      );
      card.style.setProperty(
        "--gy",
        ((event.clientY - rect.top) / rect.height) * 100 + "%",
      );
    });
  });

  /* Navigation */

  const navbar = $("navbar");
  const menuToggle = $("menuToggle");
  const navLinks = $("navLinks");

  function syncNavbar() {
    navbar.classList.toggle("scrolled", window.scrollY > 24);
  }

  function closeMenu() {
    document.body.classList.remove("menu-open");
    navbar.classList.remove("menu-active");
    navLinks.classList.remove("open");
    menuToggle.setAttribute("aria-expanded", "false");
    menuToggle.setAttribute("aria-label", "Buka menu");
  }

  function openMenu() {
    document.body.classList.add("menu-open");
    navbar.classList.add("menu-active");
    navLinks.classList.add("open");
    menuToggle.setAttribute("aria-expanded", "true");
    menuToggle.setAttribute("aria-label", "Tutup menu");
  }

  window.addEventListener("scroll", syncNavbar, { passive: true });
  syncNavbar();

  menuToggle.addEventListener("click", () => {
    const open = menuToggle.getAttribute("aria-expanded") === "true";
    open ? closeMenu() : openMenu();
  });

  navLinks.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeMenu);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeMenu();
  });

  window.addEventListener(
    "resize",
    () => {
      if (window.innerWidth > 820) closeMenu();
    },
    { passive: true },
  );

  /* Scrollspy */

  const navItems = [...document.querySelectorAll("[data-nav]")];
  const sectionIds = navItems
    .map((a) => a.getAttribute("href"))
    .filter((href) => href && href.startsWith("#"))
    .map((href) => href.slice(1));

  const sectionEls = sectionIds.map((id) => $(id)).filter(Boolean);

  if ("IntersectionObserver" in window) {
    const spy = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          const id = entry.target.id;
          navItems.forEach((a) => {
            a.classList.toggle(
              "active",
              a.getAttribute("href") === "#" + id,
            );
          });
        });
      },
      {
        threshold: 0.18,
        rootMargin: "-35% 0px -50% 0px",
      },
    );

    sectionEls.forEach((section) => spy.observe(section));
  }

  /* Reveal */

  if ("IntersectionObserver" in window) {
    const revealObs = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            revealObs.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: "0px 0px -40px 0px" },
    );

    document.querySelectorAll(".reveal").forEach((el) => {
      revealObs.observe(el);
    });
  } else {
    document.querySelectorAll(".reveal").forEach((el) => {
      el.classList.add("is-visible");
    });
  }

  /* Prototype data */

  const copyData = {
    plain: {
      growth: {
        state: "Mode Aktif",
        realm: "Fondasi Diri",
        title: "Prioritas Hari Ini",
        body: "Area ini paling butuh perhatian. Ambil satu langkah kecil yang realistis dan cukup untuk hari ini.",
        tags: ["Satu langkah", "Cukup", "Ritme aman"],
        qi: 70,
      },
      recovery: {
        state: "Mode Istirahat",
        realm: "Pemulihan",
        title: "Fokus Pemulihan",
        body: "Hari ini tidak perlu dipaksa. Turunkan beban dan pilih aksi yang hanya menjaga ritme dasar.",
        tags: ["Pemulihan", "Beban rendah", "Istirahat sah"],
        qi: 32,
      },
      tribulation: {
        state: "Mode Tantangan",
        realm: "Transformasi",
        title: "Arahkan Ulang",
        body: "Ada hambatan yang terasa nyata. Fokus pada satu tindakan yang paling menenangkan sistemmu.",
        tags: ["Hambatan aktif", "Tidak heroik", "Data dari gesekan"],
        qi: 44,
      },
      dormant: {
        state: "Mode Hening",
        realm: "Pemurnian Ulang",
        title: "Mulai Lagi",
        body: "Jika ritme sempat redup, tidak apa-apa. Kembali lewat satu tindakan kecil yang aman.",
        tags: ["Mulai lagi", "Tidak balik nol", "Aman"],
        qi: 52,
      },
    },
    hybrid: {
      growth: {
        state: "Growth Phase (生)",
        realm: "Foundation Establishment",
        title: "Breakthrough Hari Ini",
        body: "Stream ini sedang butuh Qi. Mulai dari practice 12 menit yang lembut dan bisa selesai.",
        tags: ["Qi Capacity 7/10", "Gentle enough", "One practice"],
        qi: 70,
      },
      recovery: {
        state: "Seclusion Mode (静)",
        realm: "Quiet Integration",
        title: "Seclusion Focus",
        body: "Qi-mu perlu dipulihkan, bukan dipaksa. Pilih practice yang hanya menjaga fondasi hari ini.",
        tags: [
          "Seclusion Mode",
          "Qi Capacity 3/10",
          "Recovery is cultivation",
        ],
        qi: 32,
      },
      tribulation: {
        state: "Tribulation (劫)",
        realm: "Spirit Transformation",
        title: "Bottleneck Inquiry",
        body: "Ada gesekan nyata. Cari satu tindakan yang meredakan tekanan mental, bukan yang paling megah.",
        tags: ["Friction = data", "Qi Capacity 4/10", "Witness first"],
        qi: 44,
      },
      dormant: {
        state: "Dormant Root (眠)",
        realm: "Qi Gathering",
        title: "Kembali ke Aliran",
        body: "Sistemmu sedang redup, bukan rusak. Kembali lewat satu practice sederhana tanpa tuntutan pembuktian.",
        tags: ["Quiet restart", "Qi Capacity 5/10", "The path remains"],
        qi: 52,
      },
    },
    full: {
      growth: {
        state: "炼气化神 · Cultivation Progress",
        realm: "筑基期 · Foundation Establishment",
        title: "Meridian Breakthrough",
        body: "Meridian stream ini membutuhkan sirkulasi Qi. Jalankan satu teknik sederhana untuk menghimpun energi Dantian.",
        tags: ["Qi Reservoir 7/10", "Steady circulation", "No drama"],
        qi: 70,
      },
      recovery: {
        state: "闭关静修 · Closed-Door Seclusion",
        realm: "培元期 · Quiet Integration",
        title: "Nourish the Primordial Root",
        body: "Bukan saatnya menembus batas. Hari ini adalah waktu suci untuk menjaga bejana fisik dan menenangkan Shen.",
        tags: [
          "Seclusion Chamber",
          "Qi Reservoir 3/10",
          "Retreat without shame",
        ],
        qi: 32,
      },
      tribulation: {
        state: "渡劫破除 · Heavenly Tribulation",
        realm: "化神期 · Spirit Transformation",
        title: "Heart Demon Inquiry",
        body: "Gesekan hari ini adalah guru sejati. Jangan mengejar kemenangan besar; cukup amati dan cegah penyimpangan.",
        tags: ["Tribulation", "Qi Reservoir 4/10", "Do not punish"],
        qi: 44,
      },
      dormant: {
        state: "蛰伏息定 · Winter Hibernation",
        realm: "聚气期 · Qi Gathering",
        title: "Reopen the Immortal Path",
        body: "Bahkan dunia batin membutuhkan musim dingin. Kembali bukan dari rasa malu, melainkan dari satu tarikan napas.",
        tags: ["Dormant Root", "Qi Reservoir 5/10", "Path remains"],
        qi: 52,
      },
    },
  };

  const visualsData = {
    growth: {
      core: "radial-gradient(circle at 38% 30%, #f4e4bb 0%, #88e2b0 32%, #6fae90 64%, #1a332a 100%)",
      ring: "rgba(111,174,144,0.4)",
      glow: "rgba(111,174,144,0.55)",
      glowSoft: "rgba(111,174,144,0.18)",
      accent: "#88e2b0",
      hanzi: "生",
    },
    recovery: {
      core: "radial-gradient(circle at 38% 30%, #e3f2f8 0%, #a3d9ff 30%, #7ba4c0 66%, #1f3747 100%)",
      ring: "rgba(163,217,255,0.4)",
      glow: "rgba(163,217,255,0.45)",
      glowSoft: "rgba(163,217,255,0.16)",
      accent: "#a3d9ff",
      hanzi: "静",
    },
    tribulation: {
      core: "radial-gradient(circle at 38% 30%, #f6e6cf 0%, #ffd984 22%, #d1565e 56%, #4a1a20 100%)",
      ring: "rgba(209,86,94,0.45)",
      glow: "rgba(209,86,94,0.5)",
      glowSoft: "rgba(209,86,94,0.18)",
      accent: "#ff737d",
      hanzi: "劫",
    },
    dormant: {
      core: "radial-gradient(circle at 38% 30%, #d5dedb 0%, #a4b4ac 30%, #56685f 66%, #202a26 100%)",
      ring: "rgba(164,180,172,0.25)",
      glow: "rgba(164,180,172,0.3)",
      glowSoft: "rgba(164,180,172,0.12)",
      accent: "#a4b4ac",
      hanzi: "眠",
    },
  };

  const palaces = [
    {
      id: "body",
      hanzi: "身",
      name: "Vital Stream",
      color: "#88e2b0",
      angle: -90,
      insight:
        "Tubuh adalah wadah primordial kultivasi. Saat wadah kelelahan, sistem meridian lain kehilangan pijakan energi.",
      practice:
        "Jalan kaki 12 menit di udara terbuka, lalu tiga tarikan napas Dantian yang dalam.",
    },
    {
      id: "resource",
      hanzi: "资",
      name: "Reserve Stream",
      color: "#ffd984",
      angle: -30,
      insight:
        "Sumber daya memberi batas nyata di dunia fisik. Kejernihan batin sering muncul setelah beban operasional dirapikan.",
      practice:
        "Pilih satu pengeluaran, jadwal, atau perangkat digital yang perlu dibersihkan hari ini.",
    },
    {
      id: "bond",
      hanzi: "缘",
      name: "Karma Stream",
      color: "#ffb3b8",
      angle: 30,
      insight:
        "Relasi adalah medan resonansi karmik. Tidak semua ikatan perlu intens, namun ikatan sejati perlu dirawat dengan jujur.",
      practice:
        "Kirim satu pesan singkat dan tulus kepada orang yang memberi ketenangan dalam hidupmu.",
    },
    {
      id: "heart",
      hanzi: "心",
      name: "Mind Stream",
      color: "#a3d9ff",
      angle: 90,
      insight:
        "Perhatian yang buyar meminta ruang jeda, bukan tekanan mental. Amati pusaran arus sebelum mencoba memperbaikinya.",
      practice:
        "Tulis tiga kalimat pendek: apa yang terasa berat, apa yang nyata, dan apa yang siap dilepaskan.",
    },
    {
      id: "craft",
      hanzi: "艺",
      name: "Mastery Stream",
      color: "#c3a1ff",
      angle: 150,
      insight:
        "Karya tumbuh dari ritme latihan yang konstan. Mastery tidak perlu dramatis untuk terus berkembang.",
      practice:
        "Dedikasikan 25 menit fokus penuh tanpa distraksi untuk karya atau keahlian utamamu.",
    },
    {
      id: "joy",
      hanzi: "乐",
      name: "Spirit Stream",
      color: "#f4e4bb",
      angle: 210,
      insight:
        "Sukacita menjaga akar spiritual tetap menyala. Kultivasi yang kehilangan keindahan dan rasa syukur akan cepat mengering.",
      practice:
        "Luangkan 15 menit untuk menikmati teh, musik, atau keindahan alam tanpa tuntutan produktivitas.",
    },
  ];

  const mandalaLines = $("mandalaLines");
  const palaceNodesContainer = $("palaceNodesContainer");
  const rings = ["ringOuter", "ringMiddle", "ringInner"].map($);
  const storageKey = "daoji-immortal-state";

  let currentMode = "hybrid";
  let currentState = "growth";
  let currentPalace = "body";
  let completedCount = 0;

  try {
    const saved = JSON.parse(localStorage.getItem(storageKey) || "{}");
    if (copyData[saved.mode]) currentMode = saved.mode;
    if (visualsData[saved.state]) currentState = saved.state;
    if (palaces.some((p) => p.id === saved.palace)) {
      currentPalace = saved.palace;
    }
    if (Number.isFinite(saved.cc) && saved.cc > 0) {
      completedCount = saved.cc;
    }
  } catch (_) {}

  function save() {
    try {
      localStorage.setItem(
        storageKey,
        JSON.stringify({
          mode: currentMode,
          state: currentState,
          palace: currentPalace,
          cc: completedCount,
        }),
      );
    } catch (_) {}
  }

  function svgEl(name) {
    return document.createElementNS("http://www.w3.org/2000/svg", name);
  }

  function addTag(text) {
    const tag = document.createElement("span");
    tag.className = "tag";
    tag.textContent = text;
    $("actionTags").appendChild(tag);
  }

  function initMandala() {
    const R = 195;
    const C = 260;
    const points = [];

    mandalaLines.textContent = "";
    palaceNodesContainer.textContent = "";

    palaces.forEach((palace, index) => {
      const rad = (palace.angle * Math.PI) / 180;
      const x = C + R * Math.cos(rad);
      const y = C + R * Math.sin(rad);
      points.push(`${x},${y}`);

      const line = svgEl("line");
      line.setAttribute("x1", C);
      line.setAttribute("y1", C);
      line.setAttribute("x2", x);
      line.setAttribute("y2", y);
      line.setAttribute("stroke-width", "1.2");
      line.setAttribute("stroke-dasharray", "4 8");
      line.classList.add("ml");
      mandalaLines.appendChild(line);

      const node = document.createElement("button");
      node.type = "button";
      node.className = "palace-node";
      node.dataset.palace = palace.id;
      node.style.left = `${(x / 520) * 100}%`;
      node.style.top = `${(y / 520) * 100}%`;
      node.style.animationDelay = `${index * 0.45}s`;
      node.setAttribute("aria-label", `Pilih ${palace.name}`);

      const glyph = document.createElement("span");
      glyph.className = "node-glyph";
      glyph.textContent = palace.hanzi;
      glyph.style.background = `radial-gradient(circle at 36% 30%, rgba(255,255,255,0.7), ${palace.color} 60%, ${palace.color}bb)`;

      const label = document.createElement("span");
      label.className = "node-label";
      label.textContent = palace.name.replace(" Stream", "");

      node.append(glyph, label);
      node.addEventListener("click", () => {
        currentPalace = palace.id;
        updateUI();
      });

      palaceNodesContainer.appendChild(node);
    });

    const poly = svgEl("polygon");
    poly.setAttribute("points", points.join(" "));
    poly.setAttribute("fill", "none");
    poly.setAttribute("stroke-width", "1.2");
    poly.setAttribute("stroke-dasharray", "8 14");
    poly.id = "mandPoly";
    mandalaLines.appendChild(poly);
  }

  function updateUI() {
    const text = copyData[currentMode][currentState];
    const visual = visualsData[currentState];
    const palace =
      palaces.find((item) => item.id === currentPalace) || palaces[0];
    const palaceIndex = palaces.indexOf(palace);
    const qi = Math.max(
      10,
      Math.min(100, text.qi + (palaceIndex - 2) * 4),
    );

    $("stateBadge").textContent = text.state;
    $("realmBadge").textContent = text.realm;
    $("palaceTitle").textContent = `${palace.name} (${palace.hanzi})`;
    $("palaceBody").textContent = palace.insight;
    $("actionTitle").textContent = text.title;
    $("actionBody").textContent =
      `${palace.name}: ${text.body} Practice: ${palace.practice}`;

    $("actionTags").textContent = "";
    addTag(palace.name);
    text.tags.forEach(addTag);

    $("coreHanzi").textContent = visual.hanzi;

    const core = $("dantianCore");
    core.style.background = visual.core;
    core.style.boxShadow = `0 0 50px ${visual.glow}, 0 0 130px ${visual.glowSoft}, inset 0 0 35px rgba(255,255,255,0.3)`;
    core.setAttribute(
      "aria-label",
      `Dantian core. State saat ini ${text.state}. Klik untuk mengganti state batin.`,
    );

    $("mandalaStage").style.background =
      `radial-gradient(circle at 50% 50%, ${visual.glow} 0%, transparent 60%), linear-gradient(180deg, rgba(0,0,0,0.3), rgba(13,22,20,0.4))`;

    rings.forEach((ring) => {
      ring.style.borderColor = visual.ring;
    });

    document.querySelectorAll(".ml").forEach((line) => {
      line.setAttribute("stroke", visual.ring);
    });

    const mandPoly = $("mandPoly");
    if (mandPoly) mandPoly.setAttribute("stroke", visual.ring);

    const qiBar = $("qiBarFill");
    qiBar.style.width = qi + "%";
    qiBar.style.background = `linear-gradient(90deg, ${visual.accent}, ${visual.accent}90)`;
    qiBar.style.boxShadow = `0 0 18px ${visual.glow}`;
      $("qiBarText").textContent = qi + "%";
      document
        .querySelector(".qi-meter")
        ?.setAttribute("aria-valuenow", String(qi));

    document.querySelectorAll(".palace-node").forEach((node) => {
      const active = node.dataset.palace === currentPalace;
      node.classList.toggle("active", active);
      node.setAttribute("aria-pressed", String(active));
    });

    document
      .querySelectorAll("#modeToggles .toggle-btn")
      .forEach((button) => {
        button.setAttribute(
          "aria-pressed",
          String(button.dataset.mode === currentMode),
        );
      });

    document
      .querySelectorAll("#stateToggles .toggle-btn")
      .forEach((button) => {
        button.setAttribute(
          "aria-pressed",
          String(button.dataset.state === currentState),
        );
      });

    $("completeNote").textContent =
      completedCount > 0
        ? `${completedCount} practice tersimpan lokal.`
        : "Status tersimpan lokal.";

    $("prototypeStatus").textContent =
      `${text.state}, ${palace.name}, qi ${qi} persen. ${text.title}.`;

    save();
  }

  document
    .querySelectorAll("#modeToggles .toggle-btn")
    .forEach((button) => {
      button.addEventListener("click", () => {
        currentMode = button.dataset.mode;
        updateUI();
      });
    });

  document
    .querySelectorAll("#stateToggles .toggle-btn")
    .forEach((button) => {
      button.addEventListener("click", () => {
        currentState = button.dataset.state;
        updateUI();
      });
    });

  $("completePractice").addEventListener("click", () => {
    completedCount++;
    const button = $("completePractice");

    button.textContent = "Practice Hari Ini Cukup";
    button.style.background =
      "linear-gradient(135deg, rgba(111,174,144,0.3), rgba(216,181,108,0.25))";
    button.style.borderColor = "var(--gold-glow)";
    button.style.color = "#fff";

    setTimeout(() => {
      button.textContent = "Tandai Practice Cukup";
      button.style.background = "";
      button.style.borderColor = "";
      button.style.color = "";
    }, 2200);

    updateUI();
  });

  $("dantianCore").addEventListener("click", () => {
    const order = ["growth", "recovery", "tribulation", "dormant"];
    currentState =
      order[(order.indexOf(currentState) + 1) % order.length];
    updateUI();
  });

  initMandala();
  updateUI();
})();

if ("serviceWorker" in navigator && window.location.protocol.startsWith("http")) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./sw.js").catch(() => {});
  });
}
