package servlet;

import dao.StudentDAO;
import dao.InstructorDAO;
import dao.VehicleDAO;
import dao.LessonDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final StudentDAO studentDAO = new StudentDAO();
    private final InstructorDAO instructorDAO = new InstructorDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        boolean loggedIn = req.getSession(false) != null &&
                req.getSession(false).getAttribute("loggedInUser") != null;

        String username = loggedIn ? String.valueOf(req.getSession(false).getAttribute("loggedInUser")) : "";
        String role     = "";
        if (loggedIn) {
            Object r = req.getSession(false).getAttribute("userRole");
            role = (r != null) ? r.toString() : "student";
        }

        String initial = (!username.isEmpty()) ? String.valueOf(username.charAt(0)).toUpperCase() : "U";
        String ctx     = req.getContextPath();

        int totalStudents    = loggedIn ? studentDAO.getAllStudents().size() : 0;
        int totalInstructors = loggedIn ? instructorDAO.getAllActiveInstructors().size() : 0;
        int totalVehicles    = loggedIn ? vehicleDAO.getAllActiveVehicles().size() : 0;
        int todayLessons     = loggedIn ? lessonDAO.getLessonsByDate(java.time.LocalDate.now().toString()).size() : 0;

        String error    = req.getParameter("error");
        String errorMsg = "";
        if ("invalid".equals(error))
            errorMsg = "<div class='err-box'><i class='fas fa-exclamation-circle'></i> Invalid username or password.</div>";
        else if ("empty".equals(error))
            errorMsg = "<div class='err-box'><i class='fas fa-exclamation-circle'></i> Please fill in all fields.</div>";

        String cards = "";
        if (loggedIn && "admin".equalsIgnoreCase(role)) {
            cards = "<div class='cards-grid'>" +
                    mc("fa-user-graduate",    "Student Management",   "Manage registrations, profiles and academic records.", ctx+"/students",    "#3b82f6") +
                    mc("fa-chalkboard-teacher","Instructor Management","Track availability, qualifications and lessons.",       ctx+"/instructors", "#10b981") +
                    mc("fa-car",              "Vehicle Management",   "Maintain fleet records and monitor vehicle usage.",     ctx+"/vehicles",    "#f59e0b") +
                    mc("fa-calendar-check",   "Lesson Scheduling",    "Schedule and manage practical driving lessons.",        ctx+"/lessons",     "#06b6d4") +
                    mc("fa-money-bill-wave",  "Payment Management",   "Track payments and generate financial reports.",        ctx+"/payments",    "#eab308") +
                    mc("fa-clipboard-list",   "Test Management",      "Schedule tests, record results, track progress.",       ctx+"/tests",       "#ef4444") +
                    "</div>";
        } else if (loggedIn) {
            cards = "<div class='cards-grid cards-grid-3'>" +
                    mc("fa-calendar-check",  "My Lessons",  "View your upcoming and past driving lessons.",       ctx+"/lessons",  "#06b6d4") +
                    mc("fa-clipboard-list",  "My Tests",    "Check your driving test schedule and results.",      ctx+"/tests",    "#ef4444") +
                    mc("fa-money-bill-wave", "My Payments", "View your payment history and outstanding fees.",    ctx+"/payments", "#eab308") +
                    "</div>";
        }

        resp.getWriter().println(buildHTML(ctx, loggedIn, username, role, initial,
                totalStudents, totalInstructors, totalVehicles, todayLessons, errorMsg, cards));
    }

    // ── Management card ──────────────────────────────────────────────────────
    private String mc(String icon, String title, String desc, String url, String color) {
        return "<a href='" + url + "' class='mod-card' style='--cc:" + color + "'>" +
                "<div class='mod-ico'><i class='fas " + icon + "'></i></div>" +
                "<div class='mod-body'><h3>" + title + "</h3><p>" + desc + "</p></div>" +
                "<div class='mod-arr'><i class='fas fa-arrow-right'></i></div>" +
                "</a>";
    }

    // ── Full HTML shell ───────────────────────────────────────────────────────
    private String buildHTML(String ctx, boolean loggedIn, String username, String role, String initial,
                             int students, int instructors, int vehicles, int lessons,
                             String errorMsg, String cards) {

        // Animated steering wheel logo
        String svgLogo =
                "<svg class='brand-logo-svg' width='44' height='44' viewBox='0 0 44 44' fill='none' xmlns='http://www.w3.org/2000/svg'>" +
                        "<defs>" +
                        "<linearGradient id='lgg' x1='0' y1='0' x2='44' y2='44'>" +
                        "<stop offset='0%' stop-color='#f59e0b'/><stop offset='100%' stop-color='#ef4444'/>" +
                        "</linearGradient>" +
                        "<filter id='glow'><feGaussianBlur stdDeviation='1' result='b'/>" +
                        "<feMerge><feMergeNode in='b'/><feMergeNode in='SourceGraphic'/></feMerge></filter>" +
                        "</defs>" +
                        "<rect width='44' height='44' rx='12' fill='url(#lgg)'/>" +
                        "<rect width='44' height='44' rx='12' fill='rgba(0,0,0,0.12)'/>" +
                        "<circle cx='22' cy='22' r='13' stroke='white' stroke-width='2.5' fill='none' opacity='0.95' filter='url(#glow)'/>" +
                        "<line x1='22' y1='9' x2='22' y2='22' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<line x1='22' y1='22' x2='11' y2='29' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<line x1='22' y1='22' x2='33' y2='29' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<circle cx='22' cy='22' r='3.5' fill='white'/>" +
                        "<circle cx='22' cy='22' r='1.8' fill='#f59e0b'/>" +
                        "<line x1='3' y1='17' x2='7' y2='17' stroke='white' stroke-width='1.5' stroke-linecap='round' opacity='0.35'/>" +
                        "<line x1='2' y1='22' x2='6' y2='22' stroke='white' stroke-width='1.5' stroke-linecap='round' opacity='0.25'/>" +
                        "<line x1='3' y1='27' x2='7' y2='27' stroke='white' stroke-width='1.5' stroke-linecap='round' opacity='0.35'/>" +
                        "</svg>";

        // ── Nav links ──
        String navLinks = "";
        if (loggedIn) {
            if ("admin".equalsIgnoreCase(role)) {
                navLinks =
                        "<a href='" + ctx + "/students'    class='nl'><i class='fas fa-user-graduate'></i><span>Students</span></a>" +
                                "<a href='" + ctx + "/instructors' class='nl'><i class='fas fa-chalkboard-teacher'></i><span>Instructors</span></a>" +
                                "<a href='" + ctx + "/vehicles'    class='nl'><i class='fas fa-car'></i><span>Vehicles</span></a>" +
                                "<a href='" + ctx + "/lessons'     class='nl'><i class='fas fa-calendar-check'></i><span>Lessons</span></a>" +
                                "<a href='" + ctx + "/tests'       class='nl'><i class='fas fa-clipboard-list'></i><span>Tests</span></a>" +
                                "<a href='" + ctx + "/payments'    class='nl'><i class='fas fa-money-bill-wave'></i><span>Payments</span></a>";
            } else {
                navLinks =
                        "<a href='" + ctx + "/lessons'  class='nl'><i class='fas fa-calendar-check'></i><span>My Lessons</span></a>" +
                                "<a href='" + ctx + "/tests'    class='nl'><i class='fas fa-clipboard-list'></i><span>My Tests</span></a>" +
                                "<a href='" + ctx + "/payments' class='nl'><i class='fas fa-money-bill-wave'></i><span>My Payments</span></a>";
            }
        }

        String userChip = loggedIn ?
                "<div class='u-chip'>" +
                "<div class='u-av'>" + escape(initial) + "</div>" +
                "<div class='u-info'>" +
                "<div class='u-role'>" + ("admin".equalsIgnoreCase(role) ? "Administrator" : "instructor".equalsIgnoreCase(role) ? "Instructor" : "Student") + "</div>" +
                "<div class='u-name'>" + escape(username) + "</div>" +
                "</div></div>" +
                "<a href='" + ctx + "/logout' class='logout-btn'><i class='fas fa-sign-out-alt'></i> Logout</a>"
                : "";

        String topbar =
                "<header class='topbar'>" +
                        "<a href='" + ctx + "/home' class='brand'>" +
                        svgLogo +
                        "<div><div class='brand-name'>Drive<span>Master</span></div><div class='brand-sub'>Driving Academy</div></div>" +
                        "</a>" +
                        (loggedIn ? "<nav class='nav-links'>" + navLinks + "</nav>" : "") +
                        "<div class='hdr-right'>" +
                        "<button class='theme-btn' id='themeBtn' title='Toggle theme'><i class='fas fa-moon' id='themeIcon'></i></button>" +
                        userChip +
                        "</div>" +
                        "</header>";

        String body = loggedIn
                ? getDash(role, username, students, instructors, vehicles, lessons, cards)
                : getLogin(ctx, errorMsg);

        return "<!DOCTYPE html><html lang='en' data-theme='dark'><head>" +
                "<meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'>" +
                "<title>DriveMaster Academy</title>" +
                "<link href='https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap' rel='stylesheet'>" +
                "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'>" +
                "<style>" + css() + "</style></head><body>" +
                topbar + body +
                "<footer class='footer'><p>&copy; 2025 DriveMaster Academy &mdash; Sri Lanka's Premier Driving School</p></footer>" +
                themeScript() +
                "</body></html>";
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    private String getDash(String role, String username, int s, int i, int v, int l, String cards) {
        String stats = "";
        if ("admin".equalsIgnoreCase(role)) {
            stats = "<div class='stats-row'>" +
                    statCard("fa-user-graduate",     "Total Students",    s, "#3b82f6") +
                    statCard("fa-chalkboard-teacher","Active Instructors", i, "#10b981") +
                    statCard("fa-car",               "Active Vehicles",   v, "#f59e0b") +
                    statCard("fa-calendar-check",    "Today's Lessons",   l, "#8b5cf6") +
                    "</div>";
        }

        return "<div class='dash-wrap'>" +
                "<div class='dash-hero'>" +
                "<img class='dh-bg' " +
                "src='https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=1400&q=80&auto=format&fit=crop' " +
                "alt='driving' " +
                "onerror=\"this.src='https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=1400&q=80'\"/>" +
                "<div class='dh-overlay'></div>" +
                "<div class='dh-content'>" +
                "<div class='dh-badge'><i class='fas fa-circle-check'></i> Welcome back</div>" +
                "<div class='dh-title'>Hello, <span>" + escape(username) + "</span> \uD83D\uDC4B</div>" +
                "<div class='dh-sub'>" +
                ("admin".equalsIgnoreCase(role)
                        ? "You have full admin access. Manage your entire driving academy from here."
                        : "Your personal dashboard. Track your lessons, tests and payments.") +
                "</div>" +
                "</div>" +
                "</div>" +
                stats +
                (!"".equals(cards) ? "<div class='sec-lbl'><i class='fas fa-grid-2'></i> Management Modules</div>" + cards : "") +
                "</div>" +
                "<script>document.querySelectorAll('.sv').forEach(function(el){" +
                "var t=+el.dataset.t||0,n=0,sp=Math.max(1,Math.ceil(t/40));" +
                "var tm=setInterval(function(){n=Math.min(n+sp,t);el.textContent=n;if(n>=t)clearInterval(tm);},40);});</script>";
    }

    private String statCard(String icon, String label, int val, String color) {
        return "<div class='stat' style='--sc:" + color + "'>" +
                "<div class='stat-top'>" +
                "<div class='si'><i class='fas " + icon + "'></i></div>" +
                "<div class='sv' data-t='" + val + "'>0</div>" +
                "</div>" +
                "<div class='sl'>" + label + "</div>" +
                "</div>";
    }

    // ── Login ─────────────────────────────────────────────────────────────────
    private String getLogin(String ctx, String errorMsg) {
        String loginSvg =
                "<svg class='lc-logo-svg' width='60' height='60' viewBox='0 0 44 44' fill='none'>" +
                        "<defs><linearGradient id='lg2' x1='0' y1='0' x2='44' y2='44'>" +
                        "<stop offset='0%' stop-color='#f59e0b'/><stop offset='100%' stop-color='#ef4444'/>" +
                        "</linearGradient>" +
                        "<filter id='glow2'><feGaussianBlur stdDeviation='1' result='b'/>" +
                        "<feMerge><feMergeNode in='b'/><feMergeNode in='SourceGraphic'/></feMerge></filter></defs>" +
                        "<rect width='44' height='44' rx='12' fill='url(#lg2)'/>" +
                        "<rect width='44' height='44' rx='12' fill='rgba(0,0,0,0.12)'/>" +
                        "<circle cx='22' cy='22' r='13' stroke='white' stroke-width='2.5' fill='none' opacity='0.95' filter='url(#glow2)'/>" +
                        "<line x1='22' y1='9' x2='22' y2='22' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<line x1='22' y1='22' x2='11' y2='29' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<line x1='22' y1='22' x2='33' y2='29' stroke='white' stroke-width='2' stroke-linecap='round'/>" +
                        "<circle cx='22' cy='22' r='3.5' fill='white'/>" +
                        "<circle cx='22' cy='22' r='1.8' fill='#f59e0b'/>" +
                        "</svg>";

        return "<div class='login-page'>" +
                // ── LEFT panel ──
                "<div class='lp-left'>" +
                "<div class='lp-slider'>" +
                "<img class='lp-slide active' src='https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=1200&q=85&auto=format&fit=crop' alt='car1'/>" +
                "<img class='lp-slide' src='https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=1200&q=85&auto=format&fit=crop' alt='car2'/>" +
                "<img class='lp-slide' src='https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=1200&q=85&auto=format&fit=crop' alt='car3'/>" +
                "</div>" +
                "<div class='lp-overlay'></div>" +
                "<div class='lp-content'>" +
                "<div class='lp-badge'><i class='fas fa-star'></i> Sri Lanka's #1 Driving Academy</div>" +
                "<h1 class='lp-title'>Learn to Drive.<br>Drive with <em>Confidence.</em></h1>" +
                "<p class='lp-desc'>Professional driving lessons with certified instructors. Your journey to becoming a safe, confident driver starts here.</p>" +
                "<div class='lp-feats'>" +
                feat("fa-circle-check", "Certified &amp; Experienced Instructors") +
                feat("fa-circle-check", "Modern Training Vehicles") +
                feat("fa-circle-check", "Flexible Class Scheduling") +
                feat("fa-circle-check", "Theory &amp; Practical Training") +
                "</div>" +
                "<div class='lp-thumbs'>" +
                thumb("https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=200&q=70&auto=format&fit=crop", "Practical") +
                thumb("https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=200&q=70&auto=format&fit=crop", "Highway") +
                thumb("https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=200&q=70&auto=format&fit=crop", "Training") +
                "</div>" +
                "</div>" +
                "</div>" +
                // ── RIGHT panel ──
                "<div class='lp-right'>" +
                "<div class='login-card'>" +
                "<div class='lc-top'>" + loginSvg +
                "<h2>Sign In</h2><p>Access your academy account</p>" +
                "</div>" +
                errorMsg +
                "<form action='" + ctx + "/login' method='post' class='lc-form'>" +
                "<div class='lc-field'><label>Username</label>" +
                "<div class='lc-iw'><i class='fas fa-user'></i><input type='text' name='username' placeholder='Enter your username' required></div></div>" +
                "<div class='lc-field'><label>Password</label>" +
                "<div class='lc-iw'><i class='fas fa-lock'></i><input type='password' name='password' placeholder='Enter your password' required></div></div>" +
                "<button type='submit' class='lc-btn'>Sign In <i class='fas fa-arrow-right'></i></button>" +
                "</form>" +
                "</div>" +
                "</div>" +
                "</div>" +
                // Slideshow JS
                "<script>(function(){" +
                "var slides=document.querySelectorAll('.lp-slide'),idx=0;" +
                "if(!slides.length)return;" +
                "setInterval(function(){slides[idx].classList.remove('active');idx=(idx+1)%slides.length;slides[idx].classList.add('active');},5000);" +
                "})();</script>";
    }

    private String feat(String icon, String text) {
        return "<div class='lf'><i class='fas " + icon + "'></i> " + text + "</div>";
    }

    private String thumb(String url, String label) {
        return "<div class='thumb-wrap'>" +
                "<img src='" + url + "' alt='" + label + "' class='thumb' onerror=\"this.style.display='none'\">" +
                "<div class='thumb-lbl'>" + label + "</div>" +
                "</div>";
    }

    // ── Theme toggle script (runs immediately after body) ─────────────────────
    private String themeScript() {
        return "<script>(function(){" +
                "var h=document.documentElement," +
                "b=document.getElementById('themeBtn')," +
                "ic=document.getElementById('themeIcon')," +
                "t=localStorage.getItem('dm-theme')||'dark';" +
                "h.setAttribute('data-theme',t);" +
                "ic.className=t==='dark'?'fas fa-moon':'fas fa-sun';" +
                "b.addEventListener('click',function(){" +
                "var n=h.getAttribute('data-theme')==='dark'?'light':'dark';" +
                "h.setAttribute('data-theme',n);" +
                "localStorage.setItem('dm-theme',n);" +
                "ic.className=n==='dark'?'fas fa-moon':'fas fa-sun';" +
                "});" +
                "})();</script>";
    }

    // ── CSS ───────────────────────────────────────────────────────────────────
    private String css() {
        return
                // Design tokens
                ":root{--bg:#05070d;--bg2:#08090f;--bg3:#0d1020;--border:rgba(255,255,255,0.07);--border2:rgba(255,255,255,0.11);" +
                        "--text:#ffffff;--text2:#8b93b8;--text3:#4a5278;--accent:#f59e0b;--accent2:#ef4444;" +
                        "--blue:#3b82f6;--green:#10b981;--shadow:0 8px 32px rgba(0,0,0,0.4);--nav-h:62px}" +

                        "[data-theme='light']{--bg:#f0f2fa;--bg2:#ffffff;--bg3:#e8eaf4;" +
                        "--border:rgba(0,0,0,0.07);--border2:rgba(0,0,0,0.13);" +
                        "--text:#0d0f1a;--text2:#4a5278;--text3:#9ba3c8;--shadow:0 8px 32px rgba(0,0,0,0.07)}" +

                        "*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}" +
                        "html,body{font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;transition:background .25s,color .25s}" +

                        // ── TOPBAR ──
                        ".topbar{display:flex;align-items:center;justify-content:space-between;padding:0 28px;height:var(--nav-h);" +
                        "background:rgba(3,4,8,.98);border-bottom:1px solid var(--border);" +
                        "position:sticky;top:0;z-index:300;backdrop-filter:blur(22px);gap:12px}" +
                        "[data-theme='light'] .topbar{background:rgba(255,255,255,.97)}" +

                        ".brand{display:flex;align-items:center;gap:10px;text-decoration:none;flex-shrink:0;cursor:pointer}" +
                        ".brand-name{font-size:16px;font-weight:800;color:var(--text)}" +
                        ".brand-name span{color:var(--accent)}" +
                        ".brand-sub{font-size:8.5px;color:var(--text3);text-transform:uppercase;letter-spacing:2px}" +

                        ".nav-links{display:flex;gap:2px;flex:1;justify-content:center}" +
                        ".nl{display:flex;align-items:center;gap:6px;padding:7px 12px;border-radius:9px;" +
                        "font-size:12.5px;font-weight:500;color:var(--text3);text-decoration:none;transition:all .18s;white-space:nowrap}" +
                        ".nl i{font-size:13px;width:14px;text-align:center}" +
                        ".nl:hover{background:rgba(245,158,11,.09);color:var(--accent)}" +
                        ".nl.active{background:rgba(245,158,11,.13);color:var(--accent);font-weight:600}" +

                        ".hdr-right{display:flex;align-items:center;gap:9px;flex-shrink:0}" +

                        ".theme-btn{width:36px;height:36px;border-radius:9px;border:1px solid var(--border2);" +
                        "background:var(--bg3);color:var(--text2);cursor:pointer;font-size:14px;" +
                        "display:flex;align-items:center;justify-content:center;transition:all .2s}" +
                        ".theme-btn:hover{color:var(--accent);border-color:rgba(245,158,11,.35)}" +

                        ".u-chip{display:flex;align-items:center;gap:8px;background:#06080f;" +
                        "border:1px solid var(--border2);border-radius:30px;padding:5px 14px 5px 5px}" +
                        ".u-av{width:32px;height:32px;background:linear-gradient(135deg,var(--accent),var(--accent2));" +
                        "border-radius:50%;display:flex;align-items:center;justify-content:center;" +
                        "font-weight:700;font-size:13px;color:white;flex-shrink:0}" +
                        ".u-role{font-size:9px;color:#f59e0b;text-transform:uppercase;letter-spacing:1.5px;font-weight:700}" +
                        ".u-name{font-size:12px;font-weight:700;color:var(--text)}" +

                        ".logout-btn{display:flex;align-items:center;gap:7px;padding:8px 16px;border-radius:10px;" +
                        "background:linear-gradient(135deg,var(--accent2),#c21b1b);color:white;" +
                        "text-decoration:none;font-size:12.5px;font-weight:600;transition:all .2s}" +
                        ".logout-btn:hover{transform:translateY(-1px);box-shadow:0 6px 18px rgba(239,68,68,.35)}" +

                        // ── DASHBOARD ──
                        ".dash-wrap{background:var(--bg);padding:28px;min-height:calc(100vh - var(--nav-h))}" +

                        ".dash-hero{position:relative;border-radius:20px;overflow:hidden;height:210px;" +
                        "margin-bottom:24px;animation:fadeUp .6s ease both}" +
                        ".dh-bg{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:center;filter:brightness(.45)}" +
                        ".dh-overlay{position:absolute;inset:0;background:linear-gradient(135deg,rgba(10,12,20,.88),rgba(245,158,11,.08))}" +
                        ".dh-content{position:relative;z-index:2;padding:34px 38px;height:100%;display:flex;flex-direction:column;justify-content:center}" +
                        ".dh-badge{display:inline-flex;align-items:center;gap:7px;background:rgba(245,158,11,.13);" +
                        "border:1px solid rgba(245,158,11,.3);color:var(--accent);border-radius:20px;" +
                        "padding:4px 12px;font-size:10px;font-weight:600;letter-spacing:1px;text-transform:uppercase;margin-bottom:10px;width:fit-content}" +
                        ".dh-title{font-size:30px;font-weight:800;color:#fff;margin-bottom:6px}" +
                        ".dh-title span{color:var(--accent)}" +
                        ".dh-sub{font-size:13px;color:rgba(255,255,255,.5);max-width:480px}" +

                        // Stats
                        ".stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:26px}" +
                        ".stat{background:var(--bg2);border:1px solid var(--border);border-top:3px solid var(--sc);" +
                        "border-radius:16px;padding:20px;transition:all .2s}" +
                        ".stat:hover{transform:translateY(-3px);box-shadow:0 12px 30px rgba(0,0,0,.3)}" +
                        ".stat:nth-child(1){animation:fadeUp .5s .05s ease both}" +
                        ".stat:nth-child(2){animation:fadeUp .5s .10s ease both}" +
                        ".stat:nth-child(3){animation:fadeUp .5s .15s ease both}" +
                        ".stat:nth-child(4){animation:fadeUp .5s .20s ease both}" +
                        ".stat-top{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:10px}" +
                        ".si{width:40px;height:40px;border-radius:11px;background:color-mix(in srgb,var(--sc) 14%,transparent);" +
                        "display:flex;align-items:center;justify-content:center;font-size:18px;color:var(--sc)}" +
                        ".sv{font-size:34px;font-weight:800;color:var(--text);line-height:1}" +
                        ".sl{font-size:11px;color:var(--text3);text-transform:uppercase;letter-spacing:1px}" +

                        // Module cards
                        ".sec-lbl{font-size:10.5px;font-weight:700;color:var(--text3);text-transform:uppercase;" +
                        "letter-spacing:2px;margin-bottom:14px;display:flex;align-items:center;gap:7px}" +
                        ".cards-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:13px}" +
                        ".cards-grid-3{grid-template-columns:repeat(3,1fr)}" +
                        ".mod-card{display:flex;align-items:center;gap:14px;background:var(--bg2);" +
                        "border:1px solid var(--border);border-radius:16px;padding:18px;" +
                        "text-decoration:none;color:var(--text);transition:all .25s}" +
                        ".mod-card:hover{transform:translateY(-4px);border-color:var(--cc);" +
                        "box-shadow:0 12px 32px rgba(0,0,0,.35)}" +
                        ".mod-ico{width:46px;height:46px;border-radius:13px;" +
                        "background:color-mix(in srgb,var(--cc) 13%,transparent);" +
                        "display:flex;align-items:center;justify-content:center;font-size:20px;color:var(--cc);flex-shrink:0}" +
                        ".mod-body{flex:1}" +
                        ".mod-body h3{font-size:13.5px;font-weight:700;margin-bottom:3px;color:var(--text)}" +
                        ".mod-body p{font-size:11.5px;color:var(--text3);line-height:1.45}" +
                        ".mod-arr{color:var(--text3);font-size:13px;transition:all .2s}" +
                        ".mod-card:hover .mod-arr{color:var(--cc);transform:translateX(4px)}" +
                        ".mod-card:nth-child(1){animation:fadeUp .5s .05s both}" +
                        ".mod-card:nth-child(2){animation:fadeUp .5s .10s both}" +
                        ".mod-card:nth-child(3){animation:fadeUp .5s .15s both}" +
                        ".mod-card:nth-child(4){animation:fadeUp .5s .20s both}" +
                        ".mod-card:nth-child(5){animation:fadeUp .5s .25s both}" +
                        ".mod-card:nth-child(6){animation:fadeUp .5s .30s both}" +

                        // ── LOGIN ──
                        ".login-page{display:flex;min-height:calc(100vh - var(--nav-h))}" +
                        ".lp-left{flex:1.4;position:relative;overflow:hidden;min-height:500px}" +
                        ".lp-slider{position:absolute;inset:0}" +
                        ".lp-slide{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:center;" +
                        "opacity:0;transition:opacity 1.3s ease,transform 9s ease;transform:scale(1.06)}" +
                        ".lp-slide.active{opacity:1;transform:scale(1.0)}" +
                        ".lp-overlay{position:absolute;inset:0;background:linear-gradient(120deg,rgba(5,7,20,.85) 0%,rgba(10,12,20,.6) 60%,rgba(245,158,11,.07) 100%)}" +
                        ".lp-content{position:relative;z-index:2;padding:56px 50px;height:100%;display:flex;flex-direction:column;justify-content:center}" +
                        ".lp-badge{display:inline-flex;align-items:center;gap:7px;background:rgba(245,158,11,.12);" +
                        "border:1px solid rgba(245,158,11,.28);color:var(--accent);border-radius:30px;" +
                        "padding:5px 14px;font-size:11px;font-weight:600;letter-spacing:1px;text-transform:uppercase;" +
                        "margin-bottom:20px;width:fit-content}" +
                        ".lp-title{font-size:52px;font-weight:800;color:#fff;line-height:1.1;margin-bottom:14px;text-shadow:0 2px 24px rgba(0,0,0,.5)}" +
                        ".lp-title em{color:var(--accent);font-style:normal}" +
                        ".lp-desc{font-size:14px;color:rgba(255,255,255,.55);line-height:1.75;margin-bottom:26px;max-width:430px}" +
                        ".lp-feats{display:flex;flex-direction:column;gap:10px;margin-bottom:30px}" +
                        ".lf{display:flex;align-items:center;gap:9px;font-size:13px;color:rgba(255,255,255,.78)}" +
                        ".lf i{color:var(--green);font-size:14px;flex-shrink:0}" +
                        ".lp-thumbs{display:flex;gap:12px}" +
                        ".thumb-wrap{position:relative;cursor:pointer}" +
                        ".thumb{width:112px;height:74px;object-fit:cover;border-radius:12px;" +
                        "border:2px solid rgba(255,255,255,.1);transition:all .3s;display:block}" +
                        ".thumb:hover{transform:translateY(-5px) scale(1.04);border-color:var(--accent);box-shadow:0 8px 24px rgba(0,0,0,.5)}" +
                        ".thumb-lbl{position:absolute;bottom:5px;left:0;right:0;text-align:center;" +
                        "font-size:9px;font-weight:700;color:rgba(255,255,255,.9);text-transform:uppercase;" +
                        "letter-spacing:1px;text-shadow:0 1px 4px rgba(0,0,0,.8)}" +

                        ".lp-right{width:430px;flex-shrink:0;background:var(--bg2);" +
                        "display:flex;align-items:center;justify-content:center;padding:36px;" +
                        "border-left:1px solid var(--border)}" +
                        ".login-card{width:100%;border-radius:20px;overflow:hidden;animation:fadeUp .7s ease both;" +
                        "border:1px solid var(--border);box-shadow:var(--shadow)}" +
                        ".lc-top{background:linear-gradient(135deg,var(--accent),var(--accent2));" +
                        "padding:28px;text-align:center;display:flex;flex-direction:column;align-items:center;gap:8px}" +
                        ".lc-top h2{font-size:22px;font-weight:800;color:white}" +
                        ".lc-top p{font-size:12px;color:rgba(255,255,255,.78)}" +
                        ".err-box{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.25);color:#fca5a5;" +
                        "padding:11px 16px;margin:16px 16px 0;border-radius:10px;font-size:12.5px;" +
                        "display:flex;align-items:center;gap:8px}" +
                        ".lc-form{padding:24px;display:flex;flex-direction:column;gap:16px;background:var(--bg2)}" +
                        ".lc-field{display:flex;flex-direction:column;gap:6px}" +
                        ".lc-field label{font-size:10.5px;font-weight:600;color:var(--text3);text-transform:uppercase;letter-spacing:1px}" +
                        ".lc-iw{position:relative}" +
                        ".lc-iw i{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:var(--text3);font-size:13px}" +
                        ".lc-iw input{width:100%;padding:12px 13px 12px 38px;background:var(--bg);border:1px solid var(--border2);" +
                        "border-radius:11px;color:var(--text);font-size:13.5px;font-family:'Inter',sans-serif;outline:none;transition:all .2s}" +
                        ".lc-iw input:focus{border-color:rgba(245,158,11,.5);box-shadow:0 0 0 3px rgba(245,158,11,.08)}" +
                        ".lc-iw input::placeholder{color:var(--text3)}" +
                        ".lc-btn{padding:13px;background:linear-gradient(135deg,var(--accent),var(--accent2));" +
                        "border:none;border-radius:12px;color:white;font-size:14px;font-weight:600;" +
                        "font-family:'Inter',sans-serif;cursor:pointer;transition:all .25s;" +
                        "display:flex;align-items:center;justify-content:center;gap:9px}" +
                        ".lc-btn:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(245,158,11,.35)}" +

                        // Footer
                        ".footer{text-align:center;padding:14px;color:var(--text3);font-size:11.5px;" +
                        "border-top:1px solid var(--border);background:var(--bg2)}" +

                        "@keyframes fadeUp{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}" +

                        ".brand-logo-svg{animation:logoSpin 10s linear infinite;transform-origin:center;filter:drop-shadow(0 0 7px #f59e0b55);}" +
                        ".brand:hover .brand-logo-svg{animation:logoSpin 1.5s linear infinite;filter:drop-shadow(0 0 14px #f59e0baa);}" +
                        ".lc-logo-svg{animation:logoSpin 8s linear infinite;transform-origin:center;}" +
                        "@keyframes logoSpin{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}" +
                        "@media(max-width:960px){" +
                        ".login-page{flex-direction:column}.lp-left{min-height:300px}.lp-right{width:100%}" +
                        ".lp-title{font-size:34px}.cards-grid{grid-template-columns:1fr 1fr}" +
                        ".stats-row{grid-template-columns:repeat(2,1fr)}.nav-links{display:none}" +
                        ".dash-wrap{padding:18px}" +
                        "}";
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
}