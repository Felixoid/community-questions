FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git go && \
    useradd builduser -m && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builduser && \
    rm -rf /var/cache/pacman/

USER builduser
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm && \
    cd / && \
    rm -rf /tmp/yay

# !strip saves some time
# A first python-safehttpx installation is a workaround for the issue with upstream tests
# https://github.com/gradio-app/safehttpx/issues/14
# libcurl-impersonate-bin is a quick dependency for python-curl-cffi

# pytyon-trio breaks the webscout
RUN sed -i '/^OPTIONS/ s/strip/!strip/' /etc/makepkg.conf & \
    sed '/^BUILDENV/ s/check/!check/' /etc/makepkg.conf > /tmp/makepkg.conf && \
    yay -S --noconfirm --asdeps python-build python-installer libcurl-impersonate-bin && \
    yay -S --noconfirm --makepkgconf /tmp/makepkg.conf --asdeps python-safehttpx python-build && \
    yay -S --noconfirm python-webscout && \
    yay -S --noconfirm --asdeps python-trio && \
    rm -rf ~/.cache

CMD ["python", "-m", "webscout"]
