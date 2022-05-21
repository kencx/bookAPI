from django.db import models


class Book(models.Model):
    author = models.CharField(max_length=100, blank=True)
    title = models.CharField(max_length=200, blank=True)
    completed = models.BooleanField(default=False)
    owner = models.ForeignKey(
        "auth.User", related_name="books", on_delete=models.CASCADE
    )

    def __str__(self):
        return f"{self.title} - {self.author}"

    class Meta:
        ordering = ["author"]
