import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tasks"
export default class extends Controller {
  toggleStatus(event) {
    event.preventDefault();
    const taskId = event.currentTarget.dataset.taskId;
    const icon = event.currentTarget.querySelector('i');
    const isCompleted = icon.classList.contains('text-success');
    const newStatus = !isCompleted;

    fetch(`/tasks/${taskId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').getAttribute("content")
      },
      body: JSON.stringify({ task: { completed: newStatus } })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        if (data.task.completed) {
          icon.classList.remove('text-secondary');
          icon.classList.add('text-success');
        } else {
          icon.classList.remove('text-success');
          icon.classList.add('text-secondary');
        }

        const completion = document.getElementById(`completion-${data.task.event_id}`);
        console.log(completion);
        if (completion) {
          completion.innerText = data.updated_percentage;
        }

        const taskElement = document.querySelector(`.task-info[data-task-id="${taskId}"]`);
        if (taskElement) {
          if (data.task.completed) {
            taskElement.classList.add('d-none');
          } else {
            taskElement.classList.remove('d-none');
          }
        }

        const eventId = data.task.event_id;
        const badge = document.getElementById(`event-${eventId}`)
        if (badge) {
          if (data.unfinished_tasks_count > 0) {
            badge.classList.remove('event-item-unfinished');
            badge.classList.add('event-item-finished');
          } else {
            badge.classList.remove('event-item-finished');
            badge.classList.add('event-item-unfinished');
          };
        }
      } else {
        console.error("Error updating task:", data.error)
      }
    })
    .catch(error => console.error("Fetch error:", error));
  }
}
