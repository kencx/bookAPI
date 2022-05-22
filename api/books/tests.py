from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from books.models import Book


class BookAPITestCase(APITestCase):
    user = None
    test_books = []  # type: list[Book]

    def create_test_user(self):
        if self.user is None:
            self.user = User.objects.create_user(
                "testuser", "test@example.com", "password123"
            )
        return self.user

    def setup_test_books(self, num):
        for i in range(num):
            b = Book(
                title=f"testBook{i+1}",
                author=f"testAuthor{i+1}",
                completed=False,
                owner=self.user,
            )
            b.save()
            self.test_books.append(b)

    def setUp(self):
        self.create_test_user()
        self.client.login(username="testuser", password="password123")

        self.test_books = []
        self.setup_test_books(num=3)

    def test_create_book(self):
        data = {
            "title": "testBook0",
            "author": "testAuthor0",
            "completed": False,
        }
        response = self.client.post(reverse("books-list"), data)
        book = Book.objects.get(title=data["title"])

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(book.title, data["title"])
        self.assertEqual(book.author, data["author"])
        self.assertEqual(book.completed, data["completed"])

    def test_get_books(self):
        response = self.client.get(reverse("books-list"))
        self.assertEqual(response.data["count"], len(self.test_books))

    def test_get_book(self):
        test_book = self.test_books[0]
        response = self.client.get(
            reverse("books-detail", args=[test_book.id])
        )
        book = response.data

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(book["title"], test_book.title)
        self.assertEqual(book["author"], test_book.author)
        self.assertEqual(book["completed"], test_book.completed)

    def test_update_book(self):
        test_book = self.test_books[0]
        data = {"completed": True}
        response = self.client.put(
            reverse("books-detail", args=[test_book.id]), data
        )
        book = response.data

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(book["title"], test_book.title)
        self.assertEqual(book["author"], test_book.author)
        self.assertEqual(book["completed"], data["completed"])

    def test_delete_book(self):
        test_book = self.test_books[0]
        response = self.client.delete(
            reverse("books-detail", args=[test_book.id])
        )

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(len(Book.objects.filter(id=test_book.id)), 0)
