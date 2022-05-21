from books.models import Book
from django.contrib.auth.models import User
from rest_framework import serializers


class BookSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source="owner.username")

    class Meta:
        model = Book
        fields = ["id", "title", "author", "completed", "owner"]


class UserSerializer(serializers.ModelSerializer):
    books = serializers.PrimaryKeyRelatedField(
        many=True, queryset=Book.objects.all()
    )

    class Meta:
        model = User
        fields = ["id", "username", "books"]
