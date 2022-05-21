from books.models import Book
from books.permissions import IsOwnerOrReadOnly
from books.serializers import BookSerializer, UserSerializer
from django.contrib.auth.models import User
from rest_framework import generics, permissions, viewsets


class BookViewSet(viewsets.ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [
        permissions.IsAuthenticatedOrReadOnly,
        IsOwnerOrReadOnly,
    ]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)


class BookDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
