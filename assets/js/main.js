// JavaScript for Database DevOps Autopilot

document.addEventListener("DOMContentLoaded", function () {
  // Add smooth scrolling for navigation links
  const links = document.querySelectorAll('a[href^="#"]')

  for (const link of links) {
    link.addEventListener("click", function (e) {
      e.preventDefault()

      const target = document.querySelector(this.getAttribute("href"))
      if (target) {
        target.scrollIntoView({
          behavior: "smooth",
        })
      }
    })
  }

  // Add copy button to code blocks
  const codeBlocks = document.querySelectorAll("pre code")
  codeBlocks.forEach(function (codeBlock) {
    const button = document.createElement("button")
    button.className = "copy-button"
    button.textContent = "Copy"

    button.addEventListener("click", function () {
      navigator.clipboard.writeText(codeBlock.textContent)
      button.textContent = "Copied!"
      setTimeout(() => {
        button.textContent = "Copy"
      }, 2000)
    })

    codeBlock.parentNode.insertBefore(button, codeBlock)
  })
})
