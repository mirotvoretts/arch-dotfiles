const themeToggle = document.getElementById('themeToggle');
const mobileThemeToggle = document.getElementById('mobileThemeToggle');

function toggleTheme() {
    document.body.classList.toggle('dark-theme');
    
    const isDark = document.body.classList.contains('dark-theme');
    const icon = isDark ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
    
    if (themeToggle) themeToggle.innerHTML = icon;
    if (mobileThemeToggle) mobileThemeToggle.innerHTML = icon;
    
    localStorage.setItem('theme', isDark ? 'dark' : 'light');
}

function initTheme() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.body.classList.add('dark-theme');
        const icon = '<i class="fas fa-sun"></i>';
        if (themeToggle) themeToggle.innerHTML = icon;
        if (mobileThemeToggle) mobileThemeToggle.innerHTML = icon;
    }
}

function toggleMobileMenu() {
    const mobileMenu = document.getElementById('mobileMenu');
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    
    if (!mobileMenu || !mobileMenuBtn) return;
    
    const isActive = !mobileMenu.classList.contains('active');
    mobileMenu.classList.toggle('active', isActive);
    mobileMenuBtn.classList.toggle('active', isActive);
    document.body.style.overflow = isActive ? 'hidden' : 'auto';
}

function setupMobileMenuLinks() {
    const mobileLinks = document.querySelectorAll('.mobile-menu a');
    mobileLinks.forEach(link => {
        link.addEventListener('click', () => {
            toggleMobileMenu();
        });
    });
}
    
const projectModal = document.getElementById('projectModal');

function openProjectModal() {
    if (projectModal) {
        projectModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
}

function closeProjectModal() {
    if (projectModal) {
        projectModal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }
}

function checkFormValidity() {
    const projectForm = document.getElementById('projectForm');
    const submitProjectBtn = document.getElementById('submitProjectBtn');
    
    if (!projectForm || !submitProjectBtn) return;
    
    const requiredFields = projectForm.querySelectorAll('[required]');
    submitProjectBtn.disabled = !Array.from(requiredFields).every(field => 
        field.value.trim() !== ''
    );
}

const askQuestionBtn = document.getElementById('askQuestionBtn');
const questionModal = document.getElementById('questionModal');
const closeQuestionModal = document.getElementById('closeQuestionModal');
const questionForm = document.getElementById('questionForm');

askQuestionBtn.addEventListener('click', () => {
    questionModal.style.display = 'block';
});

closeQuestionModal.addEventListener('click', () => {
    questionModal.style.display = 'none';
});

questionForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const email = document.getElementById('userEmail').value;
    const question = document.getElementById('userQuestion').value;
    
    try {
        const response = await fetch('https://your-backend-api.com/send-question', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                email,
                question
            })
        });
        
        if (response.ok) {
            alert('Ваш вопрос отправлен! Мы ответим вам в ближайшее время.');
            questionModal.style.display = 'none';
            questionForm.reset();
        } else {
            throw new Error('Ошибка отправки вопроса');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Произошла ошибка при отправке вопроса. Пожалуйста, попробуйте позже.');
    }
});

function handleProjectSubmit(e) {
    e.preventDefault();
    
    try {
        alert('Заявка успешно отправлена!');
        e.target.reset();
        closeProjectModal();
    } catch (error) {
        console.error('Ошибка отправки:', error);
        alert('Произошла ошибка при отправке');
    }
}

function initSmoothScroll() {
    const mobileMenu = document.getElementById('mobileMenu');
    
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href');
            if (targetId === '#' || targetId === '#!') return;
            
            e.preventDefault();
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                if (mobileMenu && mobileMenu.classList.contains('active')) {
                    toggleMobileMenu();
                }
                
                targetElement.scrollIntoView({ behavior: 'smooth' });
                history.pushState(null, null, targetId);
            }
        });
    });
}

let isScrolling = false;
function animateOnScroll() {
    if (isScrolling) return;
    
    isScrolling = true;
    requestAnimationFrame(() => {
        const fadeElements = document.querySelectorAll('.fade-in:not(.appear)');
        const windowHeight = window.innerHeight;
        
        fadeElements.forEach(element => {
            const elementTop = element.getBoundingClientRect().top;
            if (elementTop < windowHeight - 100) {
                element.classList.add('appear');
            }
        });
        
        isScrolling = false;
    });
}

function initFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        item.addEventListener('click', () => {
            item.classList.toggle('active');
        });
    });
}

document.addEventListener('DOMContentLoaded', () => {
	initTheme()

	if (themeToggle) themeToggle.addEventListener('click', toggleTheme)
	if (mobileThemeToggle)
		mobileThemeToggle.addEventListener('click', toggleTheme)

	const mobileMenuBtn = document.getElementById('mobileMenuBtn')
	if (mobileMenuBtn) {
		mobileMenuBtn.addEventListener('click', toggleMobileMenu)
	}

	setupMobileMenuLinks()

	const projectModal = document.getElementById('projectModal')
	const addProjectBtn = document.getElementById('addProject')
	const closeProjectModalBtn = document.getElementById('closeProjectModal')
	const projectForm = document.getElementById('projectForm')

	if (addProjectBtn) addProjectBtn.addEventListener('click', openProjectModal)
	if (closeProjectModalBtn)
		closeProjectModalBtn.addEventListener('click', closeProjectModal)

	window.addEventListener('click', e => {
		if (e.target === projectModal) closeProjectModal()
	})

	if (projectForm) {
		projectForm.addEventListener('input', checkFormValidity)
		projectForm.addEventListener('submit', handleProjectSubmit)
		checkFormValidity()
	}

	initSmoothScroll()
	initFAQ()
	animateOnScroll()

	window.addEventListener('scroll', animateOnScroll, { passive: true })

	if (window.location.hash) {
		setTimeout(() => {
			const target = document.querySelector(window.location.hash)
			if (target) target.scrollIntoView()
		}, 100)
	}

	const askQuestionBtn = document.getElementById('askQuestionBtn')
	const questionModal = document.getElementById('questionModal')
	const closeQuestionModal = document.getElementById('closeQuestionModal')
	const questionForm = document.getElementById('questionForm')

	if (askQuestionBtn) {
		askQuestionBtn.addEventListener('click', () => {
			if (questionModal) {
				questionModal.style.display = 'block'
			} else {
				console.error('Modal window not found')
			}
		})
	}

	if (closeQuestionModal) {
		closeQuestionModal.addEventListener('click', () => {
			questionModal.style.display = 'none'
		})
	}

	if (questionForm) {
		questionForm.addEventListener('submit', e => {
			e.preventDefault()
			const questionText = document.getElementById('userQuestion').value
			const userEmail = document.getElementById('userEmail').value

			console.log('Question submitted:', {
				email: userEmail,
				question: questionText,
			})
			alert('Ваш вопрос отправлен! Мы свяжемся с вами в ближайшее время.')

			questionModal.style.display = 'none'
			questionForm.reset()
		})
	}
})